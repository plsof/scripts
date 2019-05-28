#!/usr/bin/env python
# -*- coding:utf8 -*-
# date: 2018-10-08

import re
import sys
import time
import datetime

if len(sys.argv) > 1:
    INTERFACE = sys.argv[1]
else:
    INTERFACE = "eth0"
print "当前查看的网卡为：", INTERFACE

STATS = []

#定义接收流量函数
def rx():
    ifstat = open("/proc/net/dev").readlines()
    for interface in ifstat:
        if INTERFACE in interface:
            stat = float(re.split(r'[:\s]\s*', interface.strip())[1])
            STATS[0:] = [stat]

#定义发送流量函数
def tx():
    ifstat = open("/proc/net/dev").readlines()
    for interface in ifstat:
        if INTERFACE in interface:
            stat = float(re.split(r'[:\s]\s*', interface.strip())[8])
            STATS[1:] = [stat]

if __name__ == '__main__':
    f = open("/tmp/traffic", 'w+')
    print >>f, "IN -------- OUT"
    rx()
    tx()
    while True:
        time.sleep(60)
        sta_0 = list(STATS)
        rx()
        tx()
        RX = STATS[0]
        RX_0 = sta_0[0]
        TX = STATS[1]
        TX_0 = sta_0[1]
#round函数转换,保留小数点后三位
        RX_INFO = round((RX - RX_0)/1024/1024/60,3)
        TX_INFO = round((TX - TX_0)/1024/1024/60,3)
	print >>f, "%s %f MB/s %f MB/s" % (datetime.datetime.now().strftime('%Y.%m.%d-%H:%M:%S'),RX_INFO,TX_INFO)
	f.flush()
