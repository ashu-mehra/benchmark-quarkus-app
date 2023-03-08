#!/bin/bash

base() {
  export JDK="/home/asmehra/data/ashu-mehra/jdk/build/base-release/images/jdk"
  export JAR="/home/asmehra/data/ashu-mehra/quarkus-quickstarts/hibernate-orm-quickstart/target/quarkus-app/quarkus-run.jar"
  export JMX="/home/asmehra/data/ashu-mehra/quarkus-quickstarts/hibernate-orm-quickstart/jmeter.jmx"
  export JVM_OPTIONS_CREATE_CDS="-XX:+UnlockDiagnosticVMOptions -XX:+PrintMethodData"
  export EXTRA_JVM_OPTIONS="-XX:+CITime"
  export RESULTS_DIR="results_${TYPE}_${CONFIG}"
  export SERVER_CPUS="0,1,4,5"
  export NON_SERVER_CPUS="2,3,6,7"
  export JMETER_THREADS=50
  export JMETER_DURATION=300
  export STARTUP_ITERATIONS=20
  ./run.sh ${TYPE}
}

v1() {
  export JDK="/home/asmehra/data/ashu-mehra/jdk/build/persist-profile-info-cds-release/images/jdk"
  export JAR="/home/asmehra/data/ashu-mehra/quarkus-quickstarts/hibernate-orm-quickstart/target/quarkus-app/quarkus-run.jar"
  export JMX="/home/asmehra/data/ashu-mehra/quarkus-quickstarts/hibernate-orm-quickstart/jmeter.jmx"
  export JVM_OPTIONS_CREATE_CDS="-XX:+DumpMethodData -XX:+UnlockDiagnosticVMOptions -XX:+PrintMethodData"
  export EXTRA_JVM_OPTIONS="-XX:+CITime -XX:-EnableEarlyTier2Compilation -XX:-PrintMethodDataFromCDS"
  export RESULTS_DIR="results_${TYPE}_${CONFIG}"
  export SERVER_CPUS="0,1,4,5"
  export NON_SERVER_CPUS="2,3,6,7"
  export JMETER_THREADS=50
  export JMETER_DURATION=300
  export STARTUP_ITERATIONS=20
  ./run.sh ${TYPE}
}

v2() {
  export JDK="/home/asmehra/data/ashu-mehra/jdk/build/persist-profile-info-cds-release/images/jdk"
  export JAR="/home/asmehra/data/ashu-mehra/quarkus-quickstarts/hibernate-orm-quickstart/target/quarkus-app/quarkus-run.jar"
  export JMX="/home/asmehra/data/ashu-mehra/quarkus-quickstarts/hibernate-orm-quickstart/jmeter.jmx"
  export JVM_OPTIONS_CREATE_CDS="-XX:+DumpMethodData -XX:+UnlockDiagnosticVMOptions -XX:+PrintMethodData"
  export JVM_OPTIONS="-XX:+CITime -XX:+EnableEarlyTier2Compilation -XX:-PrintMethodDataFromCDS"
  export RESULTS_DIR="results_${TYPE}_${CONFIG}"
  export SERVER_CPUS="0,1,4,5"
  export NON_SERVER_CPUS="2,3,6,7"
  export JMETER_THREADS=50
  export JMETER_DURATION=300
  export STARTUP_ITERATIONS=20
  ./run.sh ${TYPE}
}

TYPE="tput"
#TYPE="startup"

CONFIG=$1
[ -z ${CONFIG} ] && CONFIG="base"
case ${CONFIG} in
  base)
    base
    ;;
  v1)
    v1
    ;;
  v2)
    v2
    ;;
  *)
    echo "unknown CONFIGuration ${CONFIG} requested"
esac
