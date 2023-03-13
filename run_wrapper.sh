#!/bin/bash

quarkus() {
  export JAR="/home/asmehra/data/ashu-mehra/quarkus-quickstarts/hibernate-orm-quickstart/target/quarkus-app/quarkus-run.jar"
  export JAR_FILE_NAME="quarkus-run.jar"
  export JMX="/home/asmehra/data/ashu-mehra/quarkus-quickstarts/hibernate-orm-quickstart/jmeter.jmx"
  export NEED_DB=1
  export STARTUP_TIMEOUT=15
  export STARTUP_KEYWORD="started in"
  export STOP_COMMAND="kill"

  # Options for JMeter for actual run
  export JMETER_THREADS_RUN=50
  export JMETER_DURATION_RUN=300

}

spring() {
  export JAR="/home/asmehra/data/ashu-mehra/spring-petclinic/target/spring-petclinic-3.0.0-SNAPSHOT.jar"
  export JAR_FILE_NAME=".spring-petclinic-3.0.0-SNAPSHOT.jar"
  export JMX="/home/asmehra/data/ashu-mehra/spring-petclinic/src/test/jmeter/petclinic_test_plan_modified.jmx"
  export NEED_DB=0
  export STARTUP_TIMEOUT=60
  export STARTUP_KEYWORD="Started PetClinicApplication"
  export STOP_COMMAND="curl -X POST localhost:8080/actuator/shutdown"

  # Options for JMeter for actual run
  export JMETER_THREADS_RUN=50
  export JMETER_DURATION_RUN=1200
}

dacapo() {
  export JAR="/home/asmehra/data/ashu-mehra/dacapo-9.12-MR1-bach.jar"
  export JAR_FILE_NAME="dacapo-9.12-MR1-bach.jar"
  export NEED_DB=0
  export APP_ARGS="--iterations 20 ${DACAPO_BENCHMARK}"
}

common() {
  [ -z ${RESULTS_DIR} ] && export RESULTS_DIR="${APP}/results_${TYPE}_${CONFIG}"
  export CREATE_CDS_ARCHIVE=0
  export USE_CSET="1"
  export SERVER_CPUS="2,3"
  export NON_SERVER_CPUS="0,1"
  export APP_NAME="${APP}"

  # Options for startup config
  export STARTUP_ITERATIONS=1
}

# Specific configurations

base() {
  export JDK="/home/asmehra/data/ashu-mehra/jdk/build/base-release/images/jdk"
  if [ ${APP} = "dacapo" ]; then
    export CDS_NAME="${CDS_ARTIFACT}/${DACAPO_BENCHMARK}-nopd.jsa"
  else
    export CDS_NAME="${CDS_ARTIFACT}/${APP}-nopd.jsa"
  fi

  # Options for actual run
  export EXTRA_JVM_OPTIONS="-XX:SharedArchiveFile=${CDS_NAME} -XX:+CITime -XX:+PrintCompilation"
  # export EXTRA_JVM_OPTIONS="-XX:SharedArchiveFile=${CDS_NAME} -XX:+CITime -XX:+CIPrintRequests -XX:+PrintTieredEvents -XX:+PrintCompilation"
}

base_nomd() {
  export JDK="/home/asmehra/data/ashu-mehra/jdk/build/base-release/images/jdk"
  if [ ${APP} = "dacapo" ]; then
    export CDS_NAME="${CDS_ARTIFACT}/${DACAPO_BENCHMARK}-nopd.jsa"
  else
    export CDS_NAME="${CDS_ARTIFACT}/${APP}-nopd.jsa"
  fi

  # Options for actual run
  export EXTRA_JVM_OPTIONS="-XX:SharedArchiveFile=${CDS_NAME} -XX:+CITime -XX:+PrintCompilation -XX:+UnlockDiagnosticVMOptions -XX:-ProfileInterpreter -XX:-C1UpdateMethodData"
}

base_onlytier1() {
  export JDK="/home/asmehra/data/ashu-mehra/jdk/build/base-release/images/jdk"
  if [ ${APP} = "dacapo" ]; then
    export CDS_NAME="${CDS_ARTIFACT}/${DACAPO_BENCHMARK}-nopd.jsa"
  else
    export CDS_NAME="${CDS_ARTIFACT}/${APP}-nopd.jsa"
  fi

  # Options for actual run
  export EXTRA_JVM_OPTIONS="-XX:SharedArchiveFile=${CDS_NAME} -XX:+CITime -XX:TieredStopAtLevel=1"

}

base_onlytier2() {
  export JDK="/home/asmehra/data/ashu-mehra/jdk/build/base-release/images/jdk"
  if [ ${APP} = "dacapo" ]; then
    export CDS_NAME="${CDS_ARTIFACT}/${DACAPO_BENCHMARK}-nopd.jsa"
  else
    export CDS_NAME="${CDS_ARTIFACT}/${APP}-nopd.jsa"
  fi

  # Options for actual run
  export EXTRA_JVM_OPTIONS="-XX:SharedArchiveFile=${CDS_NAME} -XX:+CITime -XX:TieredStopAtLevel=2"

}

base_nojit() {
  export JDK="/home/asmehra/data/ashu-mehra/jdk/build/base-release/images/jdk"
  if [ ${APP} = "dacapo" ]; then
    export CDS_NAME="${CDS_ARTIFACT}/${DACAPO_BENCHMARK}-nopd.jsa"
  else
    export CDS_NAME="${CDS_ARTIFACT}/${APP}-nopd.jsa"
  fi

  # Options for actual run
  export EXTRA_JVM_OPTIONS="-Xint -XX:SharedArchiveFile=${CDS_NAME}"
}

v1() {
  export JDK="/home/asmehra/data/ashu-mehra/jdk/build/persist-profile-info-cds-release/images/jdk"
  if [ ${APP} = "dacapo" ]; then
    export CDS_NAME="${CDS_ARTIFACT}/${DACAPO_BENCHMARK}-pd.jsa"
  else
    export CDS_NAME="${CDS_ARTIFACT}/${APP}-pd.jsa"
  fi

  # Options for actual run
  export EXTRA_JVM_OPTIONS="-XX:SharedArchiveFile=${CDS_NAME} -XX:-EnableEarlyTier2Compilation -XX:-PrintMethodDataFromCDS -XX:+CITime -XX:+PrintCompilation"
}

v2() {
  export JDK="/home/asmehra/data/ashu-mehra/jdk/build/persist-profile-info-cds-release/images/jdk"
  if [ ${APP} = "dacapo" ]; then
    export CDS_NAME="${CDS_ARTIFACT}/${DACAPO_BENCHMARK}-pd.jsa"
  else
    export CDS_NAME="${CDS_ARTIFACT}/${APP}-pd.jsa"
  fi

  # Options for actual run
  export EXTRA_JVM_OPTIONS="-XX:SharedArchiveFile=${CDS_NAME} -XX:+EnableEarlyTier2Compilation -XX:-PrintMethodDataFromCDS -XX:+CITime"
}

v3() {
  export JDK="/home/asmehra/data/ashu-mehra/jdk/build/persist-profile-info-cds-release/images/jdk"
  if [ ${APP} = "dacapo" ]; then
    export CDS_NAME="${CDS_ARTIFACT}/${DACAPO_BENCHMARK}-pd.jsa"
  else
    export CDS_NAME="${CDS_ARTIFACT}/${APP}-pd.jsa"
  fi

  # Options for actual run
  export EXTRA_JVM_OPTIONS="-XX:SharedArchiveFile=${CDS_NAME} -XX:+EnableEarlyTier2Compilation -XX:-PrintMethodDataFromCDS -XX:+CITime -XX:Tier2InvokeNotifyFreqLog=7"
}

v4() {
  export JDK="/home/asmehra/data/ashu-mehra/jdk/build/persist-profile-info-do-tier2-comp-release/images/jdk"
  if [ ${APP} = "dacapo" ]; then
    export CDS_NAME="${CDS_ARTIFACT}/${DACAPO_BENCHMARK}-pd.jsa"
  else
    export CDS_NAME="${CDS_ARTIFACT}/${APP}-pd.jsa"
  fi

  # Options for actual run
  export EXTRA_JVM_OPTIONS="-XX:SharedArchiveFile=${CDS_NAME} -XX:-EnableEarlyTier2Compilation -XX:-PrintMethodDataFromCDS -XX:+CITime -XX:Tier2InvokeNotifyFreqLog=7 -XX:+IfProfileDataIsAvailableDoTier2"
}

v5() {
  export JDK="/home/asmehra/data/ashu-mehra/jdk/build/base-release/images/jdk"
  if [ ${APP} = "dacapo" ]; then
    export CDS_NAME="${CDS_ARTIFACT}/${DACAPO_BENCHMARK}-nopd.jsa"
  else
    export CDS_NAME="${CDS_ARTIFACT}/${APP}-nopd.jsa"
  fi

  # Options for actual run
  export EXTRA_JVM_OPTIONS="-XX:SharedArchiveFile=${CDS_NAME} -XX:+CITime -XX:Tier2InvokeNotifyFreqLog=7"
}

test() {
  #export JDK="/home/asmehra/data/ashu-mehra/jdk/build/base-release/images/jdk"
  export JDK="/home/asmehra/data/ashu-mehra/jdk/build/persist-profile-info-cds-release/images/jdk"
  export CDS_NAME="${CDS_ARTIFACT}/${APP}-pd.jsa"

  # Options for actual run
  # export EXTRA_JVM_OPTIONS="-XX:SharedArchiveFile=${CDS_NAME} -XX:+CITime -XX:+UnlockDiagnosticVMOptions -XX:+DumpPerfMapAtExit -XX:+PreserveFramePointer"
  export EXTRA_JVM_OPTIONS="-XX:SharedArchiveFile=${CDS_NAME} -XX:-EnableEarlyTier2Compilation -XX:-PrintMethodDataFromCDS -XX:+CITime -XX:+PrintCompilation"
}

CONFIG=$1
[ -z ${CONFIG} ] && CONFIG="base"

APP=$2
[ -z ${APP} ] && APP="quarkus" # valid value: quarkus, spring

TYPE=$3
[ -z ${TYPE} ] && TYPE="tput" # valid value: tput, startup

if [ ${APP} = "dacapo" ]; then
  DACAPO_BENCHMARK=$4
  [ -z ${DACAPO_BENCHMARK} ] && DACAPO_BENCHMARK="avrora"
  CDS_ARTIFACT="cds_artifact/dacapo/${DACAPO_BENCHMARK}"
else
  CDS_ARTIFACT="cds_artifact/${APP}"
fi

common

case ${CONFIG} in
  base)
    base
    ;;
  base_nomd)
    base_nomd
    ;;
  base_onlytier1)
    base_onlytier1
    ;;
  base_onlytier2)
    base_onlytier2
    ;;
  base_nojit)
    base_nojit
    ;;
  v1)
    v1
    ;;
  v2)
    v2
    ;;
  v3)
    v3
    ;;
  v4)
    v4
    ;;
  v5)
    v5
    ;;
  test)
    test
    ;;
  *)
    echo "unknown config \"${CONFIG}\" requested"; exit 1;
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
    echo "unknown app \"${APP}\" requested"; exit 1;
esac

./tune_system.sh

./run.sh ${TYPE}

./reset_system.sh
