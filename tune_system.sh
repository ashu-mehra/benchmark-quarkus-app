#!/bin/bash

# disable turbo boost
#sudo sh -c "echo 0 > /sys/devices/system/cpu/cpufreq/boost"
sudo sh -c "/bin/echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo"

# disable THP
sudo sh -c "/bin/echo "never" > /sys/kernel/mm/transparent_hugepage/enabled"

# clear OS caches
sync && sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"

# disable SMP
sudo sh -c "/bin/echo off > /sys/devices/system/cpu/smt/control"

# set cpu frequency governor
#sudo cpupower -c "${SERVER_CPUS}" frequency-set -g userspace
#sudo cpupower -c "${SERVER_CPUS}" frequency-set -f 2500MHz

# disable irqbalance daemon
sudo systemctl stop irqbalance

# set IRQ affinity
sudo sh -c "/bin/echo 03 > /proc/irq/default_smp_affinity"
for f in `ls /proc/irq/*/smp_affinity`; do sudo sh -c "echo 03 > $f" &> /dev/null; done

SERVER_CPUS="2,3"
if [ "${USE_CSET}" = "1" ]; then
  sudo rmdir /sys/fs/cgroup/cpuset/machine.slice # remove any docker cpuset
  sudo rmdir /sys/fs/cgroup/cpuset/system/machine.slice # remove any docker cpuset
  sudo /home/asmehra/data/ashu-mehra/cpuset/cset shield --reset
  sudo /home/asmehra/data/ashu-mehra/cpuset/cset shield -c ${SERVER_CPUS} -k on
fi
