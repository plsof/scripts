#!/bin/bash
# author pdd 2017/8/09

URI="xxx"

tomcats=( \
10.1.32.13 \
10.1.32.92 \
10.1.32.93 \
10.1.32.21 \
10.1.32.22 \
10.1.32.25 \
10.1.32.28 \
10.1.32.63 \
10.1.32.65 \
10.1.32.66 \
10.1.32.96 \
10.1.32.117 \
10.1.32.118 \
10.1.32.119 \
10.1.32.120 )

ports=( 6100 6101 6102 6103 6104 )

for port in "${ports[@]}"
do
    for tomcat in "${tomcats[@]}"
    do
        echo "$tomcat:$port"
        curl --connect-timeout 5 "http://$tomcat:$port/$URI" >> $tomcat-$port
        sleep 0.5
        echo
    done
done
