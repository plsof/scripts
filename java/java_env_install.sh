#!/bin/bash
# author pdd 2017/06/22

# create user tomcat

USER="tomcat"

grep -s $USER /etc/passwd || useradd tomcat

mkdir -p /data/app

mkdir /data/tools

mkdir -p /data/logs/tomcat && chown -R $USER:$USER /data/logs/tomcat

function JDK_Install() {
    cd /usr/local/src
    tar -zx -f ./jdk-7u79-linux-x64.tar.gz -C /data/tools
    ln -s /data/tools/jdk1.7.0_79 /data/tools/jdk
    cp /etc/profile /etc/profile$(date "+%y%m%d")
    echo "\nexport PATH=/data/tools/jdk/bin:$PATH" >>/etc/profile
    echo "export JAVA_HOME=/data/tools/jdk" >>/etc/profile
    source /etc/profile
}

java -version
result=$?

[ result = 0 ] || JDK_Install
