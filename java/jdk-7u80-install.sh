#!/bin/bash
# author pdd 2017/12/12

# create user tomcat
USER="tomcat"

grep -q $USER /etc/passwd || useradd tomcat

mkdir -p /data/app

mkdir -p /data/tools

mkdir -p /data/logs/tomcat && chown -R $USER:$USER /data/logs/tomcat

function JDK_Install() {
    cd /usr/local/src
    tar -zx -f ./jdk-7u80-linux-x64.tar.gz -C /data/tools
    ln -sf /data/tools/jdk1.7.0_80 /data/tools/jdk
    cp /etc/profile /etc/profile$(date "+%y%m%d")
    echo -e "\nexport PATH=/data/tools/jdk/bin:$PATH" >>/etc/profile
    echo "export JAVA_HOME=/data/tools/jdk" >>/etc/profile
    echo "install jdk successfully"
}

java -version >/dev/null 2>&1
result=$?

[ "$result" = 0 ] && echo "jdk has been already installed" || JDK_Install
