#!/bin/bash

if [ $# -ne "1" ]; then
  echo "Insufficient arguments"
  exit 1
fi

pid=$1

if [ ! -z ${pid} ]; then
  echo "+++++++++++++++++++++++++++++++"
  echo $pid_list
  top -b -d 1 -p $pid 
  echo "###############################"
fi
