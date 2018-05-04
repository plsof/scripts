#!/bin/bash
# 2018-04-28 pdd

OUT_DIR=/data/tmp/mongo_backup
DATE=$(date "-d -1 days" "+%Y_%m_%d")
KDATE=$(date "-d -3 days" "+%Y_%m_%d") # keep 2 backup files

[ -d $OUT_DIR/$DATE ] || mkdir -p $OUT_DIR/$DATE

/data/server/mongodb_27017/bin/mongodump -o $OUT_DIR/$DATE

cd $OUT_DIR; tar -zcv -f $DATE.tar.gz $DATE

[ -e $DATE ] && rm -rf $DATE
[ -e $KDATE.tar.gz ] && rm -f $KDATE.tar.gz
