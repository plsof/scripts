#!/bin/bash

# WTV EPG
LOGFILE="/data/nginxlogs/looktvepg.access.log"

for d in $(seq 20181010 20181014)
do
    echo $d
    echo -e -n "\tALL "
    awk '{a[$4]++} END{for(i in a) print a[i],i}' ${LOGFILE}${d} | sort -n | tail -n 1
    echo -e -n "\tMISS "
    awk '{if ($NF ~ "MISS") a[$4]++} END{for(i in a) print a[i],i}' ${LOGFILE}${d} | sort -n | tail -n 1
    echo
done
