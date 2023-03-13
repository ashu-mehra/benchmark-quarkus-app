#!/bin/bash

quarkus() {
  export JAR="/home/asmehra/data/ashu-mehra/quarkus-quickstarts/hibernate-orm-quickstart/target/quarkus-app/quarkus-run.jar"
  export JAR_FILE_NAME="quarkus-run.jar"
  export JMX="/home/asmehra/data/ashu-mehra/quarkus-quickstarts/hibernate-orm-quickstart/jmeter.jmx"
  export NEED_DB=1
  export STARTUP_TIMEOUT=15
  export STARTUP_KEYWORD="started in"
  export STOP_COMMAND="kill"
}

spring() {
  export JAR="/home/asmehra/data/ashu-mehra/spring-petclinic/target/spring-petclinic-3.0.0-SNAPSHOT.jar"
  export JAR_FILE_NAME="spring-petclinic-3.0.0-SNAPSHOT.jar"
  export JMX="/home/asmehra/data/ashu-mehra/spring-petclinic/src/test/jmeter/petclinic_test_plan_modified.jmx"
  export NEED_DB=0
  export STARTUP_TIMEOUT=60
  export STARTUP_KEYWORD="Started PetClinicApplication"
  export STOP_COMMAND="curl -X POST localhost:8080/actuator/shutdown"
}

dacapo() {
  export JAR="/home/asmehra/data/ashu-mehra/dacapo-9.12-MR1-bach.jar"
  export JAR_FILE_NAME="dacapo-9.12-MR1-bach.jar"
  export NEED_DB=0
  export APP_ARGS="--iterations 20 ${DACAPO_BENCHMARK}"
}

common() {
  [ -z ${RESULTS_DIR} ] && RESULTS_DIR="${CDS_ARTIFACT}/results_${CONFIG}"
  echo "RESULTS_DIR=${RESULTS_DIR}"
  export RESULTS_DIR
  export CREATE_CDS_ARCHIVE=1
  export USE_CSET="1"
  export SERVER_CPUS="2,3"
  export NON_SERVER_CPUS="0,1"
  export APP_NAME="${APP}"

  # Options for JMeter when creating CDS archive
  export JMETER_THREADS_CREATE_CDS=50
  export JMETER_DURATION_CREATE_CDS=300
}

# Specific configurations

nopd() {
  export JDK="/home/asmehra/data/ashu-mehra/jdk/build/base-release/images/jdk"
  if [ ${APP} = "dacapo" ]; then
    export CDS_NAME="${CDS_ARTIFACT}/${DACAPO_BENCHMARK}-${CONFIG}.jsa"
  else
    export CDS_NAME="${CDS_ARTIFACT}/${APP}-${CONFIG}.jsa"
  fi

  # Options when creating CDS archive
  export JVM_OPTIONS_CREATE_CDS="-XX:ArchiveClassesAtExit=${CDS_NAME} -XX:+UnlockDiagnosticVMOptions -XX:+PrintMethodData"
}

pd() {
  export JDK="/home/asmehra/data/ashu-mehra/jdk/build/persist-profile-info-cds-release/images/jdk"
  if [ ${APP} = "dacapo" ]; then
    export CDS_NAME="${CDS_ARTIFACT}/${DACAPO_BENCHMARK}-${CONFIG}.jsa"
  else
    export CDS_NAME="${CDS_ARTIFACT}/${APP}-${CONFIG}.jsa"
  fi

  # Options when creating CDS archive
  export JVM_OPTIONS_CREATE_CDS="-XX:ArchiveClassesAtExit=${CDS_NAME} -XX:+DumpMethodData -XX:+UnlockDiagnosticVMOptions -XX:+PrintMethodData"
}

tune_system() {
  sudo /home/asmehra/data/ashu-mehra/cpuset/cset shield -c ${SERVER_CPUS} -k on
}

reset_system() {
  sudo /home/asmehra/data/ashu-mehra/cpuset/cset shield --reset
}

CONFIG=$1
[ -z ${CONFIG} ] && CONFIG="nopd"

APP=$2
[ -z ${APP} ] && APP="quarkus" # valid value: quarkus, spring, dacapo

if [ ${APP} = "dacapo" ]; then
  DACAPO_BENCHMARK=$3
  [ -z ${DACAPO_BENCHMARK} ] && DACAPO_BENCHMARK="avrora"
  CDS_ARTIFACT="cds_artifact/dacapo/${DACAPO_BENCHMARK}"
else
  CDS_ARTIFACT="cds_artifact/${APP}"
fi

common

case ${CONFIG} in
  nopd)
    nopd
  ;;
  pd)
    pd
  ;;
  *)
    echo "unknown CONFIG"; exit 1;
esac

case ${APP} in
  quarkus)
    quarkus
    ;;
  spring)
    spring
    ;;
  dacapo)
    dacapo
    ;;
  *)
    echo "unknown app \"${APP}\" requested"
esac

./tune_system.sh

./run.sh

./reset_system.sh
