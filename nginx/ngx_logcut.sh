#!/bin/bash

# 01 00 * * * /data/nginxlogs/ngx_logcut.sh  >/dev/null 2>&1

pidfile=/var/run/nginx.pid
logpath='/data/nginxlogs/'
keepdays=5 # keep 8 log files

#logfiles=( *.log )

cd $logpath

#for logfile in ${logfiles[@]}; do
for logfile in `ls *log`
do
    if [ ! -e $logfile ];
    then
        continue
    fi
    find . -type f -name $logfile"20*" -mtime +$keepdays -exec ionice -c3 rm -f {} \;
    mv $logfile $logfile$(date -d "yesterday" +"%Y%m%d")
done

kill -USR1 `cat $pidfile`
