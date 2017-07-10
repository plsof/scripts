#!/usr/bin/env python
# -*- coding:utf-8 -*-

import os
import re
import sys
import json

class Ngx_Conf_Summary(object):

    def __init__(self, filepath, upstream):
        self.result = {}
        self.backend = []
        self.filepath = filepath
        self.upstream = upstream
        self.backend_pattern = r'upstream\s+%s\s*{([^}]*)}' % self.upstream
        self.backend_host_pattern = r'(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}):(\d{1,5})'
        with open(self.filepath,'r') as f:
            self.content = f.read().strip()
        
    def _get_backend_hosts_(self):
        backend_list_test = re.search(self.backend_pattern,self.content)
        if backend_list_test is not None:
            backend_list = backend_list_test.group(1).split(';')
            for backend_servers in backend_list:
                if backend_servers.strip().startswith('#') or not backend_servers:
                    pass
                else:
                    backend_host = re.findall(self.backend_host_pattern,backend_servers.strip())
                    if backend_host:
                        self.backend.append((backend_host[0][0],backend_host[0][1]))
                       
        else:
            print json.dumps({
                "error" : "%s not defind" % self.upstream
            })
            sys.exit(1)

        return self.backend

    def summary(self):
        hosts = self._get_backend_hosts_()
        # remove redundant host and aggregate the port
        for host in hosts:
            if self.result.has_key(host[0]):
                self.result[host[0]].append(host[1])
            else:
                self.result[host[0]] = [host[1]]
        print "server        port"
        for server,port in self.result.iteritems():
            print "%s    %s" % (server, " ".join(port))
        print

if __name__ == '__main__':

    filepath = '/etc/nginx.conf' #  absolute path
    upstream = 'proxysrv1'
    if os.path.exists(filepath):
        ngx_conf=Ngx_Conf_Summary(filepath, upstream)
        ngx_conf.summary()
    else:
        print json.dumps({
		"error" : "%s not found" % filepath
	})
