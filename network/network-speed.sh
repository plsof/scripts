#!/bin/bash
# pdd 20171025

ip -f inet addr | egrep -w -v "127.0.0.1|lo" |  grep inet | awk '{print $NF,$2}' | while read label address
do
    echo -n "$label $address"
    ethtool $label | grep Speed
done
