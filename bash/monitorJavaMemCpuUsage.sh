#!/bin/bash
rm -f monitorJavaMemCpuUsage.log
touch monitorJavaMemCpuUsage.log

# ps aux --sort=+pid | awk 'NR==1 || /[j]ava/' >> monitorJavaMemCpuUsage.log
echo "-----------------------------------------------" >> monitorJavaMemCpuUsage.log
ps -eo pid,%mem,%cpu,command --sort=pid | awk 'NR==1 || /[j]ava/' | sed "s#^#$(date +%Y"-"%m"-"%d"_"%H"."%M"."%S) #" >> monitorJavaMemCpuUsage.log

## Use pidstat ??
#e.g. to monitor these two process IDs (12345 and 11223) every 5 seconds use
#$ pidstat -h -r -u -v -p 12345,11223 5

## Use ttop ??
# https://serverfault.com/questions/387268/linux-cpu-usage-and-process-execution-history

##
## Check : https://linuxconfig.org/ps-output-difference-between-vsz-vs-rss-memory-usage
