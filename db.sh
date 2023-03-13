#!/bin/bash

CONTAINER="quarkus-test-db"
if [ $1 == "start" ]; then
  if [ ${USE_CSET} = "1" ]; then
    sudo docker run -d --name ${CONTAINER} -e POSTGRES_USER=quarkus_test -e POSTGRES_PASSWORD=quarkus_test -e POSTGRES_DB=quarkus_test -p 5432:5432 postgres:latest &> /dev/null
  else
    sudo docker run -d --cpuset-cpus=0,1 --name ${CONTAINER} -e POSTGRES_USER=quarkus_test -e POSTGRES_PASSWORD=quarkus_test -e POSTGRES_DB=quarkus_test -p 5432:5432 postgres:latest &> /dev/null
  fi
  exit $?
fi
if [ $1 == "stop" ]; then
  sudo docker stop ${CONTAINER}
  sudo docker rm ${CONTAINER}
fi
