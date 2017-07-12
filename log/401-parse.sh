#!/bin/bash
# 2017/07/04 @pdd

set -e

OPATH="/data/data/loger/stb/kadun-401/kadun-"

if [ -z "$1" ];then
    echo -e "USAGE: code [num]"
    exit 1
fi

code=$1

if [ "$2" -ge 1 ];then
    TIME=$(/bin/date -d "-$2 days" "+%Y-%m-%d")
else
    TIME=$(/bin/date "+%Y-%m-%d")
fi

file=${OPATH}${TIME}*
tmpfile="/tmp/401-log"

function Parse() {
    /bin/awk -F '[()/, ]' -v num=$1 '($4==num) {{n++;printf "%s %s %s %s %s %s %s",n,$9,$10,$32,$28,$30,$31}{for(i=36;i<=NF;i++){printf "/%s",$i}{printf"\n"}}}' $file
}

function Parse_to_file() {
    /bin/awk -F '/' -v num=$1 '($4==num) {print $0}' $file > $tmpfile
    /bin/awk -F '[()/, ]' '{{n++;printf "%s %s %s %s %s %s %s",n,$9,$10,$32,$28,$30,$31}{for(i=36;i<=NF;i++){printf "/%s",$i}{printf"\n"}}}' $tmpfile
}

#which function to use
Parse_to_file $code
#Parse $code
