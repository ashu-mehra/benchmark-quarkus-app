#!/bin/bash

run_config() {
  for CONFIG in ${CONFIGS}; do
    for i in `seq 1 ${WARMUPS}`; do
      echo "Warmup run $i"
      echo "-------------"
      if [ ${APP} = "dacapo" ]; then
        export RESULTS_DIR="${APP}/${DACAPO_BENCHMARK}/${CONFIG}/${TYPE}-warmup-${i}"
        ./run_wrapper.sh ${CONFIG} ${APP} ${TYPE} ${DACAPO_BENCHMARK}
      else
        export RESULTS_DIR="${APP}/${CONFIG}/${TYPE}-warmup-${i}"
        ./run_wrapper.sh ${CONFIG} ${APP} ${TYPE} 
      fi
      sleep 5s
    done
  
    for i in `seq 1 ${ITERATIONS}`; do
      echo "Measure run $i"
      echo "--------------"
      if [ ${APP} = "dacapo" ]; then
        export RESULTS_DIR="${APP}/${DACAPO_BENCHMARK}/${CONFIG}/${TYPE}-${i}"
        ./run_wrapper.sh ${CONFIG} ${APP} ${TYPE} ${DACAPO_BENCHMARK} 
      else
        export RESULTS_DIR="${APP}/${CONFIG}/${TYPE}-${i}"
        ./run_wrapper.sh ${CONFIG} ${APP} ${TYPE} 
      fi
      sleep 5s
    done
  done
}

CONFIGS="v4" #"base v1 v2 v3 v4 v5"
APP="spring"
WARMUPS=0
ITERATIONS=5
TYPE="tput"

if [ ${APP} = "dacapo" ]; then
  BENCHMARKS="avrora fop h2 jython luindex lusearch-fix pmd sunflow xalan"
  for bench in ${BENCHMARKS}; do
    echo "Starting Dacapo benchmark $bench"
    echo "--------------------------------"
    DACAPO_BENCHMARK=${bench}
    run_config
  done
else
  run_config
fi

