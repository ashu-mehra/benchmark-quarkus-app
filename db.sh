#!/bin/bash

CONTAINER="quarkus-test-db"
if [ $1 == "start" ]; then
  sudo docker run -d --cpuset-cpus=2,3,6,7 --name ${CONTAINER} -e POSTGRES_USER=quarkus_test -e POSTGRES_PASSWORD=quarkus_test -e POSTGRES_DB=quarkus_test -p 5432:5432 postgres:latest &> /dev/null
  exit $?
fi
if [ $1 == "stop" ]; then
  sudo docker stop ${CONTAINER}
  sudo docker rm ${CONTAINER}
fi
