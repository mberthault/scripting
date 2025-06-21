#!/bin/bash
rm -f monitorJavaMemCpuUsage.log
touch monitorJavaMemCpuUsage.log

# ps aux --sort=+pid | awk 'NR==1 || /[j]ava/' >> monitorJavaMemCpuUsage.log
echo "-----------------------------------------------" >> monitorJavaMemCpuUsage.log
ps -eo pid,%mem,%cpu,command --sort=pid | awk 'NR==1 || /[j]ava/' | sed "s#^#$(date +%Y"-"%m"-"%d"_"%H"."%M"."%S) #" >> monitorJavaMemCpuUsage.log
