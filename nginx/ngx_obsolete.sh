#!/bin/bash
# pdd 20171027

#clear

cd /usr/local/nginx/conf/conf.d

for i in $(ls *.conf | egrep -v "cmsc_0proxy|status")
do
    echo
    echo "#---------------------------------------------------------------------#"
    echo "$i"
    egrep "listen|server_name|access_log" $i | egrep -v "^\s*#"
    echo
    grep "access_log" $i | egrep -v "^\s*#" | while read log logpath format
    do
        echo ${logpath%;}"*"
        #echo "the log accessing num and volume for a week"
        #wc -l ${logpath}*
        du -s -h -c  ${logpath%;}* | grep total
    done
    echo "#---------------------------------------------------------------------#"
    echo
done
