#!/bin/bash

# enable turbo boost
#sudo sh -c "echo 1 > /sys/devices/system/cpu/cpufreq/boost"
sudo sh -c "/bin/echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo"

# enable THP
sudo sh -c "/bin/echo "always" > /sys/kernel/mm/transparent_hugepage/enabled"

# enable SMP
sudo sh -c "/bin/echo on > /sys/devices/system/cpu/smt/control"

# set cpu frequency governor to performance
#sudo cpupower -c "${SERVER_CPUS}" frequency-set -g performance 

# set IRQ affinity
sudo sh -c "/bin/echo 0f > /proc/irq/default_smp_affinity"
for f in `ls /proc/irq/*/smp_affinity`; do sudo sh -c "echo 0f > $f" &> /dev/null; done

# remove cset shield
if [ ${USE_CSET} = "1" ]; then
  sudo rmdir /sys/fs/cgroup/cpuset/machine.slice # remove any docker cpuset
  sudo rmdir /sys/fs/cgroup/cpuset/system/machine.slice # remove any docker cpuset
  sudo /home/asmehra/data/ashu-mehra/cpuset/cset shield --reset
fi
