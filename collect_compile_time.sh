#!/bin/bash

JDK=$1
APP_PID=$2
LOG_FILE=$3

while [ -d /proc/${APP_PID} ];
do
  ${JDK}/bin/jcmd ${APP_PID} Compiler.time &>> ${LOG_FILE}
  sleep 1s
done

