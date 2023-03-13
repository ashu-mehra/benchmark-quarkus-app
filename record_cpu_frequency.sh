#!/bin/bash

DIR=$1

while true; do
  grep "cpu MHz" /proc/cpuinfo | tail -n 2 | head -n 1 >> ${DIR}/cpu2.freq
  grep "cpu MHz" /proc/cpuinfo | tail -n 2 | tail -n 1 >> ${DIR}/cpu3.freq
  sleep 1s
done
