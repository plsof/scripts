#!/bin/bash
# author pdd 20171010

clear

LogFile="/tmp/log"

awk 'BEGIN{size=0}{if ($8 ~ /[0-9][0-9][0-9]/) status[$8]++;size+=$9} \
	END{printf "\nPV:\n\n\t %s Count\n\n",NR; \
	printf "HTTP code percentage:\n\n"; \
	for(i in status)printf "\t%s  %s line  %f%\n",substr(i,2,3),status[i],status[i]/NR*100; \
	printf "\nflow sent to client: \n\n\t %s MB\n\n",size/1024/1024}' $LogFile
