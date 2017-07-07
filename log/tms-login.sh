#!/bin/bash
#2017/07/05 @pdd
# egrep "015164026490197|015164026498133|015164026498581|015164026496744|015164026495932|015373001004176" /nginxlogs/tms.access.log

LOG="/nginxlogs/tms.access.log"

MIN=$1

# minutes must great than 30
if [[ -n "$1" && "$1" > 30 ]];then
    PRETIME=$(date -d "-$1 min" "+%Y-%m-%dT%T")
else
    PRETIME=$(date -d "-30 min" "+%Y-%m-%dT%T")
fi

TIME="["${PRETIME}"+08:00]"

# 时间 HTTP状态码 串号 节点
awk -v actime=$TIME '$4 >= actime {print $4,$8,substr($12,1,15),$15}' $LOG | awk '{if($3==015164026498581) print "徐总1在线",$0; else if($3==015164026490197) print "徐总2在线"; else if($3==015164026496744) print "夏总在线",$0; else if($3==015164026498133) print "候总在线",$0; else if($3==015164026495932) print "高伟在线",$0; else($3==015373001004176) print "杜鹏在线",$0}'
