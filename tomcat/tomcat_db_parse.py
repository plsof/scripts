#!/usr/bin/env python
# -*- coding:utf-8 -*-
# author pdd 2017/07/16

import re
import os
import subprocess

class DB_Parse(object):

    def __init__(self, servlets, war):
        self.servlets = servlets
        self.war = war

    def redis_parse(self):
        for servlet in self.servlets:
            print servlet
            warpath = "webapps/%s/WEB-INF/classes/redis.properties" % self.war
            redispath = os.path.join(servlet.rstrip("/"), warpath)
            with open(redispath, 'r') as rf:
                rc = rf.read().strip()
            rh = re.search(r"^\s*redis_master.ip\s*=\s*(.*)", rc, re.M)
            if rh is None:
                print "Cant't find redis host"
            else:
                rhost = rh.group(1).strip()
                rr = re.match(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}', rhost)
                if rr is not None:
                    print "use ip\t%s" % rhost
                else:
                    rcmd = "grep %s /etc/hosts | grep -v ^.*#" % rhost
                    rip = subprocess.Popen(rcmd, shell=True, stdout=subprocess.PIPE)
                    rresult = rip.stdout.readlines()[0].strip().split()
                    print "%s %s" % (rresult[0], rresult[1])
            rp = re.search(r"^\s*redis_master.port\s*=\s*(.*)", rc, re.M)
            if rp is None:
                print "Cant't find redis port"
            else:
                rport = rp.group(1).strip()
                print "redis port: %s\n" % rport

    def mysql_parse(self):
        for servlet in self.servlets:
            print servlet
            mysqlpath01 = os.path.join(servlet.rstrip("/"), "conf/server.xml")
            mysqlpath02 = os.path.join(servlet.rstrip("/"), "conf/context.xml")
            object = re.compile(r"jdbc:mysql://(.*):(\w+)/(\w+)?")
            with open(mysqlpath01, 'r') as mf1:
                mc1 = mf1.read().strip()
            mh1 = object.findall(mc1)
            with open(mysqlpath02, 'r') as mf2:
                mc2 = mf2.read().strip()
            mh2 = object.findall(mc2)
            if len(mh1) == 0 and len(mh2) == 0:
                print "No MySQL"
		continue
            else:
                mh = (mh2 if len(mh1) == 0 else mh1)
            for host in mh:
                mr = re.match(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}', host[0])
                if mr is not None:
                    print "use ip\t%s" % host[0]
                else:
                    mcmd = "grep %s /etc/hosts | grep -v ^.*#" % host[0]
                    mip = subprocess.Popen(mcmd, shell=True, stdout=subprocess.PIPE)
                    streamdata = mip.communicate()[0]
                    returncode = mip.returncode
                    if returncode == 0:
                        mresult = streamdata.strip().split()
                        print "%s %s" % (mresult[0], mresult[1])
                    else:
                        print "Can't find mysql in /etc/hosts"
                print "mysql port: %s" % host[1]
                print "mysql db: %s" % host[2]
	    print

if __name__ == "__main__":

    servlets = [ "/data/app/tomcat-test-8080",
  		 "/data/app/tomcat-test-8081",
		 "/data/app/tomcat-test-8082",
		 "/data/app/tomcat-test-8082",
    ]
    war = 'test.war'
    process = DB_Parse(servlets, war)
    process.redis_parse()
    process.mysql_parse()
