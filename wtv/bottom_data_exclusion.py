#!/usr/bin/env python
# -*- coding:utf8 -*-

import os
import json
import sqlite3
import urllib2

TEMPLATES = ['0281', '0282', '0283', '02838', '0284', '02861', '0285', '02862', '02837', '02860', '0286', '0287', '02836', '0288', '02832', '02833', '02831', '02830', '02827', '0289', '0290', '02858', '02826', '02857', '02825', '0291', '02824', '02856', '0292', '02823', '02855', '0293', '02822', '02854', '0294', '02821', '02853', '0295', '02820', '02851', '0296', '02818', '02813', '02852', '02812', '66666', '02811', '0297', '02850', '02810', '02849', '02848', '02828', '02847', '02846', '02829', '02843', '02814', '02842', '02815', '02841', '02840', '02839', '88884', '02859', '02863', '02801', '02802', '02803', '02804', '02805', '02806', '02844', '0790']

# EXCLUSION_UUID = ['ysten-cctv-1', 'cctv-2', 'cctv-3']
EXCLUSION_UUID = []

URL = "http://127.0.0.1:6000/ysten-lvoms-epg/epg/getChannels.shtml?templateId=%s"

def ctable(c, template):
    sql = "CREATE TABLE w%s(id integer primary key autoincrement, uuid char(50) not null unique, no int not null);" % template
    c.execute(sql)


def wuuid(c, template, url):
    try:
        response = urllib2.urlopen(url, timeout=1)
    except urllib2.URLError:
        print "url timeout"  # 接口超时
        return  # 退出当前循环
    else:
        data = json.load(response)
        if data == []:
            print "online %s empty" % template
        else:
            for item in data:
                if item['uuid'] not in EXCLUSION_UUID:
                    sql = "insert into w%s (uuid, no) values ('%s', %d)" % (template, item['uuid'], item['no'])
                    c.execute(sql)


if __name__ == '__main__':

    dbfile = os.path.exists('/data/tmp/wtv.db')
    if dbfile == True:
        os.remove('/data/tmp/wtv.db')
    conn = sqlite3.connect('/data/tmp/wtv.db')
    c = conn.cursor()
    for template in TEMPLATES:
        ctable(c, template)
        url = URL % template
        wuuid(c, template, url)
    conn.commit()
    print "Records created successfully"
    conn.close()
