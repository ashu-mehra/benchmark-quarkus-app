#!/bin/bash

quarkus() {
  export JAR="/home/asmehra/data/ashu-mehra/quarkus-quickstarts/hibernate-orm-quickstart/target/quarkus-app/quarkus-run.jar"
  export JMX="/home/asmehra/data/ashu-mehra/quarkus-quickstarts/hibernate-orm-quickstart/jmeter.jmx"
  export NEED_DB=1
  export STARTUP_TIMEOUT=10
  export STARTUP_KEYWORD="started in"
}

spring() {
  export JAR="/home/asmehra/data/ashu-mehra/spring-petclinic/target/spring-petclinic-3.0.0-SNAPSHOT.jar"
  export JMX="/home/asmehra/data/ashu-mehra/spring-petclinic/src/test/jmeter/petclinic_test_plan_modified.jmx"
  export NEED_DB=0
  export STARTUP_TIMEOUT=20
  export STARTUP_KEYWORD="Started PetClinicApplication"
}

common() {
  export RESULTS_DIR="${APP}/results_${TYPE}_${CONFIG}"
  export CDS_NAME="${CDS_ARTIFACT}/quarkus-${CONFIG}.jsa"
  export CREATE_CDS_ARCHIVE=1
  export SERVER_CPUS="0,1,4,5"
  export NON_SERVER_CPUS="2,3,6,7"
  export APP_NAME="${APP}"

  # Options for JMeter when creating CDS archive
  export JMETER_THREADS_CREATE_CDS=50
  export JMETER_DURATION_CREATE_CDS=300

  # Options for JMeter for actual run
  export JMETER_THREADS_RUN=50
  export JMETER_DURATION_RUN=300

  # Options for startup config
  export STARTUP_ITERATIONS=20
}

# Specific configurations

base() {
  export JDK="/home/asmehra/data/ashu-mehra/jdk/build/base-release/images/jdk"

  # Options when creating CDS archive
  export JVM_OPTIONS_CREATE_CDS="-XX:ArchiveClassesAtExit=${CDS_NAME} -XX:+UnlockDiagnosticVMOptions -XX:+PrintMethodData"

  # Options for actual run
  export EXTRA_JVM_OPTIONS="-XX:SharedArchiveFile=${CDS_NAME} -XX:+CITime"

}

base_nojit() {
  export JDK="/home/asmehra/data/ashu-mehra/jdk/build/base-release/images/jdk"

  # Options when creating CDS archive
  export JVM_OPTIONS_CREATE_CDS="-XX:ArchiveClassesAtExit=${CDS_NAME} -XX:+UnlockDiagnosticVMOptions -XX:+PrintMethodData"

  # Options for actual run
  export EXTRA_JVM_OPTIONS="-Xint -XX:SharedArchiveFile=${CDS_NAME}"
}

v1() {
  export JDK="/home/asmehra/data/ashu-mehra/jdk/build/persist-profile-info-cds-release/images/jdk"

  # Options when creating CDS archive
  export JVM_OPTIONS_CREATE_CDS="-XX:ArchiveClassesAtExit=${CDS_NAME} -XX:+DumpMethodData -XX:+UnlockDiagnosticVMOptions -XX:+PrintMethodData"

  # Options for actual run
  export EXTRA_JVM_OPTIONS="-XX:+CITime -XX:-EnableEarlyTier2Compilation -XX:-PrintMethodDataFromCDS"
}

v2() {
  export JDK="/home/asmehra/data/ashu-mehra/jdk/build/persist-profile-info-cds-release/images/jdk"

  # Options when creating CDS archive
  export JVM_OPTIONS_CREATE_CDS="-XX:ArchiveClassesAtExit=${CDS_NAME} -XX:+DumpMethodData -XX:+UnlockDiagnosticVMOptions -XX:+PrintMethodData"

  # Options for actual run
  export EXTRA_JVM_OPTIONS="-XX:+CITime -XX:+EnableEarlyTier2Compilation -XX:-PrintMethodDataFromCDS"
}

CONFIG=$1
[ -z ${CONFIG} ] && CONFIG="base"

APP=$2
[ -z ${APP} ] && APP="quarkus"

TYPE="tput"
#TYPE="startup"

CDS_ARTIFACT="${APP}/cds_artifact"
if [ ! -d ${CDS_ARTIFACT} ]; then
  mkdir -p ${CDS_ARTIFACT}
fi

common

case ${CONFIG} in
  base)
    base
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
  *)
    echo "unknown config \"${CONFIG}\" requested"
esac

case ${APP} in
  quarkus)
    quarkus
    ;;
  spring)
    spring
    ;;
  *)
    echo "unknown app \"${APP}\" requested"
esac

./run.sh ${TYPE}
