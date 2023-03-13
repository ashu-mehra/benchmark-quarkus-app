#!/bin/bash

# set -e 

ulimit -c unlimited

cleanup_results() {
  local dir=$1
  echo "Cleaning ${dir}"
  rm -fr ${dir}/*
}

check_app_started() {
  local counter=0
  local max_iterations=${STARTUP_TIMEOUT}
  while [ "${counter}" -lt "${max_iterations}" ];
  do
    grep "${STARTUP_KEYWORD}" ${APP_LOG_FILE} &> /dev/null
    if [ $? -eq "0" ]; then
      return 0
    fi
    sleep 1s
    counter=$(( $counter+1 ))
  done
  return 1
}

start_app() {
  echo "Starting app with"
  echo "  JDK: ${JDK}"
  echo "  JVM_OPTIONS: ${JVM_OPTIONS}"
  echo "  APP_LOG_FILE: ${APP_LOG_FILE}"
  echo "  JAR: ${JAR}"

  if [ -z ${SERVER_CPUS} ]; then
    ${JDK}/bin/java ${JVM_OPTIONS} -jar ${JAR} &> ${APP_LOG_FILE} &
  else
    taskset -c ${SERVER_CPUS} ${JDK}/bin/java ${JVM_OPTIONS} -jar ${JAR} &> ${APP_LOG_FILE} &
  fi

  APP_PID=`echo $!`
  check_app_started
  local rc=$?
  if [ ${rc} -ne "0" ];
  then
    echo "Application is taking too long to startup...Exiting"
    exit 1
  fi
}

start_jmeter() {
  if [ -z ${SERVER_CPUS} ]; then
    /home/asmehra/data/ashu-mehra/apache-jmeter-5.5/bin/jmeter -JDURATION=${JMETER_DURATION} -JTHREADS=${JMETER_THREADS} -Dsummariser.interval=6 -n -t ${JMX} | tee ${JMETER_OUTPUT} &
  else
    taskset -c ${NON_SERVER_CPUS} /home/asmehra/data/ashu-mehra/apache-jmeter-5.5/bin/jmeter -JDURATION=${JMETER_DURATION} -JTHREADS=${JMETER_THREADS} -Dsummariser.interval=6 -n -t ${JMX} | tee ${JMETER_OUTPUT} &
  fi
  JMETER_PID=`echo $!`
}

create_cds_archive() {
  start_app
  echo "Started quarkus app: ${APP_PID}"
  # Run jmeter load for 3 mins
  echo "Starting load for ${JMETER_DURATION} seconds"

  start_jmeter
  echo "Started jmeter load: ${JMETER_PID}"
  echo "Waiting for jmeter load to complete"
  wait ${JMETER_PID}

  kill ${APP_PID} &> /dev/null
  wait ${APP_PID}
}

run_startup() {
  for i in `seq 1 ${STARTUP_ITERATIONS}`; do
    echo "Startup iteration ${i}"
    ./loop-curl.sh & 
    stime=`date +"%s %3N"`
    echo "Start time: ${stime}"
    start_app
    sleep 1s # after starting the app 1 sec should be enough to wait for completing the first request
    kill -9 ${APP_PID}

    awk '/started in/{ print $16 }' ${APP_LOG_FILE} | cut -d 's' -f 1 >> ${RESULTS_DIR}/startup

    # Get the time to first request
    read -a tokens <<< ${stime}
    stime=$(( ${tokens[0]}*1000+${tokens[1]} ))
    etime=`awk -F '=' '/Request time=/{ print $2 }' ${APP_LOG_FILE}`
    echo "End time: ${etime}"
    diff=`echo "scale=3; $(( ${etime}-${stime} ))/1000" | bc`
    echo "${diff}" >> ${RESULTS_DIR}/ttfr
  done
}

run_tput() {
  TOP_OUTPUT="${RESULTS_DIR}/top.out"
  MEM_OUTPUT="${RESULTS_DIR}/memory.out"
  CPU_OUTPUT="${RESULTS_DIR}/cpu.out"
  STATS_FILE="${RESULTS_DIR}/stats"

  start_app
  echo "Started quarkus app: ${APP_PID}"

  # Start collecting compile times
  if [ -z ${SERVER_CPUS} ]; then
    ./collect_compile_time.sh ${JDK} ${APP_PID} ${COMPILE_LOGS} &
  else
    taskset -c ${NON_SERVER_CPUS} ./collect_compile_time.sh ${JDK} ${APP_PID} ${COMPILE_LOGS} &
  fi
 
  # Run jmeter load
  echo "Starting jmeter load for ${JMETER_DURATION} seconds with ${JMETER_THREADS} threads"

  start_jmeter
  echo "Started jmeter load: ${JMETER_PID}"

  # Start top process to monitor CPU and memory stats
  if [ -z ${SERVER_CPUS} ]; then
    ./run_top.sh "${APP_PID}" &> ${TOP_OUTPUT} &
  else
    taskset -c ${NON_SERVER_CPUS} ./run_top.sh "${APP_PID}" &> ${TOP_OUTPUT} &
  fi
  sleep 1s
  TOP_PID=`ps -ef | grep "top -b" | grep -v grep | awk '{ print $2 }'`
  echo "Top process: ${TOP_PID}"

  echo "Waiting for jmeter load to complete"
  wait ${JMETER_PID}

  # Terminate the processes
  kill -9 ${TOP_PID} &> /dev/null
  kill -9 ${APP_PID} &> /dev/null

  grep "${APP_PID}" ${TOP_OUTPUT} | grep "java" | awk '{ print $6 }' &> ${MEM_OUTPUT}
  grep "${APP_PID}" ${TOP_OUTPUT} | grep "java" | awk '{ print $9 }' &> ${CPU_OUTPUT}

  max_mem=`cat ${MEM_OUTPUT} | sort -n | tail -n 1`
  avg_cpu=`awk 'BEGIN{sum=0}{sum += $1}END{print sum/NR}' ${CPU_OUTPUT}`

  # Get CPU, memory and throughput stats
  awk '/summary \+/' ${JMETER_OUTPUT} > ${RESULTS_DIR}/tputlines
  awk '{ print $5 }' ${RESULTS_DIR}/tputlines > ${RESULTS_DIR}/jmeter.time
  awk -F ":" 'BEGIN { total=0 } { total += $3; print total }' ${RESULTS_DIR}/jmeter.time > ${RESULTS_DIR}/times
  awk '{ print $7 }' ${RESULTS_DIR}/tputlines | cut -d '/' -f 1 > ${RESULTS_DIR}/rampup
  tail -n 20 ${RESULTS_DIR}/rampup > ${RESULTS_DIR}/rampup.last2mins
  
  echo "time,tput" > ${RESULTS_DIR}/rampup.table
  paste -d "," ${RESULTS_DIR}/times ${RESULTS_DIR}/rampup >> ${RESULTS_DIR}/rampup.table
  rm -f ${RESULTS_DIR}/jmeter.time ${RESULTS_DIR}/times

  avg_tput=`awk '/summary =/{ print $7 }' ${JMETER_OUTPUT} | tail -n 1 | cut -d '/' -f 1`
  avg_tput_last2min=`cat ${RESULTS_DIR}/rampup.last2mins | awk 'BEGIN{sum=0}{sum += $1}END{print sum/NR}'`
  peak_tput=`cat ${RESULTS_DIR}/rampup | sort -n | tail -n 1`
  peak_tput_last2min=`cat ${RESULTS_DIR}/rampup.last2mins | sort -n | tail -n 1`

  echo "Overall Avg tput: ${avg_tput}" | tee -a ${STATS_FILE}
  echo "Overall Peak tput: ${peak_tput}" | tee -a ${STATS_FILE}
  echo "Avg tput (last 2 mins): ${avg_tput_last2min}" | tee  -a ${STATS_FILE}
  echo "Peak tput (last 2 mins): ${peak_tput_last2min}" | tee  -a ${STATS_FILE}

  echo "Peak memory: ${max_mem} KB" | tee -a ${STATS_FILE}
  echo "Avg CPU utilization: ${avg_cpu}" | tee -a ${STATS_FILE}

  # Get compilation stats
  awk '/Tier1/{ print $10 }' ${COMPILE_LOGS} > ${RESULTS_DIR}/tier1
  awk '/Tier2/{ print $10 }' ${COMPILE_LOGS} > ${RESULTS_DIR}/tier2
  awk '/Tier3/{ print $10 }' ${COMPILE_LOGS} > ${RESULTS_DIR}/tier3
  awk '/Tier4/{ print $10 }' ${COMPILE_LOGS} > ${RESULTS_DIR}/tier4
  echo "Tier1,Tier2,Tier3,Tier4" > ${RESULTS_DIR}/compilestats
  paste -d "," ${RESULTS_DIR}/tier1 ${RESULTS_DIR}/tier2 ${RESULTS_DIR}/tier3 ${RESULTS_DIR}/tier4 >> ${RESULTS_DIR}/compilestats
  rm -f ${RESULTS_DIR}/tier1 ${RESULTS_DIR}/tier2 ${RESULTS_DIR}/tier3 ${RESULTS_DIR}/tier4
}

# Env variables that need to be defined:
#   JDK: (required) Location of JDK to use
#   JAR: (required) Location of application jar file
#   JMX: (required) Location of jmeter test plan
#   RESULTS_DIR: (optional) Location where logs are stored
#   CREATE_CDS_ARCHIVE: (optional) set to 1 if CDS archive should be created before running the actual test
#   SERVER_CPUS: (optional) set of CPUs on which the app process is run; it not set app may contend for CPU with other processes
#   NON_SERVER_CPUS: (optional) set of CPUs on which other processes are run
#
#   JVM_OPTIONS_CREATE_CDS: (optiona) JVM options to use when creating CDS archive file
#   JMETER_THREADS_CREATE_CDS: (optional) JMeter threads when creating CDS archive
#   JMETER_DURATION_CREATE_CDS: (optional) JMeter duration when creating CDS archive
#
#   EXTRA_JVM_OPTIONS: (optional) JVM options to use in actual run
#   JMETER_THREADS_RUN: (optional) JMeter threads for actual throughput run
#   JMETER_DURATION_RUN: (optional) JMeter duration for actual throughput run 

# For startup run
#   STARTUP_ITERATIONS: (optional) number of iterations for startup and time-to-first-request (ttfr) measurements
 
if [ -z ${JDK} ]; then
  echo "JDK is missing"
  exit 1;
fi
if [ -z ${JAR} ]; then
  echo "JAR is missing"
  exit 1;
fi
if [ -z ${JMX} ]; then
  echo "JMX is missing"
  exit 1;
fi
if [ -z "${STARTUP_KEYWORD}" ]; then
  echo "STARTUP_KEYWORD is missing"
  exit 1;
fi

# Set default values for optional env variable if they were not define
[ -z "${CREATE_CDS_ARCHIVE}" ] && CREATE_CDS_ARCHIVE=1
[ -z "${RESULTS_DIR}" ] && RESULTS_DIR="results"
[ -z "${STARTUP_TIMEOUT}" ] && STARTUP_TIMEOUT=10

JMETER_DURATION_DEFAULT=15
JMETER_THREADS_DEFAULT=50
STARTUP_ITERATIONS_DEFAULT=5

if [ ! -d ${RESULTS_DIR} ]; then
  mkdir -p ${RESULTS_DIR}
else
  cleanup_results "${RESULTS_DIR}"
fi

# Check the parameters
type=$1
if [ -z "${type}" ]; then echo "Type of run (startup or tput) not specified"; exit 1; fi

APP_PID=`ps -ef | grep "quarkus-run.jar" | grep -v grep | awk '{ print $2 }'`
if [ ! -z "${APP_PID}" ];
then
  echo "Quarkus app (pid: ${APP_PID}) is already running. Stop it first."
  echo "Exiting"
  exit 1
fi

if [ ${NEED_DB} -eq 1 ]; then
  ./db.sh "start"
fi

sleep 2s

if [ ${CREATE_CDS_ARCHIVE} -eq 1 ]; then
  echo "Creating CDS archive"

  APP_LOG_FILE="${RESULTS_DIR}/${APP_NAME}.dump.log"
  JMETER_OUTPUT="${RESULTS_DIR}/jmeter.dump.log"

  # Create CDS archive file
  JVM_OPTIONS="${JVM_OPTIONS_CREATE_CDS}"
  JMETER_THREADS="${JMETER_THREADS_CREATE_CDS}"
  JMETER_DURATION="${JMETER_DURATION_CREATE_CDS}"

  [ -z "${JMETER_DURATION}" ] && JMETER_DURATION="${JMETER_DURATION_DEFAULT}"
  [ -z "${JMETER_THREADS}" ] && JMETER_THREADS="${JMETER_THREADS_DEFAULT}"

  create_cds_archive
fi

# Do actual run
APP_LOG_FILE="${RESULTS_DIR}/${APP_NAME}.log"
JMETER_OUTPUT="${RESULTS_DIR}/jmeter.log"
JVM_OPTIONS="${EXTRA_JVM_OPTIONS}"
JMETER_THREADS="${JMETER_THREADS_RUN}"
JMETER_DURATION="${JMETER_DURATION_RUN}"

[ -z "${JMETER_DURATION}" ] && JMETER_DURATION="${JMETER_DURATION_DEFAULT}"
[ -z "${JMETER_THREADS}" ] && JMETER_THREADS="${JMETER_THREADS_DEFAULT}"

if [ $type == "tput" ]; then
  COMPILE_LOGS="${RESULTS_DIR}/compile.log"
  run_tput
else
  [ -z "${STARTUP_ITERATIONS}" ] && STARTUP_ITERATIONS="${STARTUP_ITERATIONS_DEFAULT}"
  run_startup
fi

if [ ${NEED_DB} -eq 1 ]; then
  ./db.sh "stop"
fi
