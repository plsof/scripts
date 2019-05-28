#!/usr/bin/env python
# -*- coding:utf8 -*-

import time
import json
import threading
import sqlite3
import urllib2

# TEMPLATES = ['0281', '0282', '0283', '02838', '0284', '02861', '0285', '02862', '02837', '02860', '0286', '0287', '02836', '0288', '02832', '02833', '02831', '02830', '02827', '0289', '0290', '02858', '02826', '02857', '02825', '0291', '02824', '02856', '0292', '02823', '02855', '0293', '02822', '02854', '0294', '02821', '02853', '0295', '02820', '02851', '0296', '02818', '02813', '02852', '02812', '66666', '02811', '0297', '02850', '02810', '02849', '02848', '02828', '02847', '02846', '02829', '02843', '02814', '02842', '02815', '02841', '02840', '02839', '88884', '02859', '02863', '02801', '02802', '02803', '02804', '02805', '02806', '02844', '0790']
TEMPLATES = ['0282', '0283', '0286', '0290', '0297', '02810', '02814', '02815', '02830', '02831', '02838', '02840', '02850']

URL_UUID = "http://127.0.0.1:6000/ysten-lvoms-epg/epg/getChannels.shtml?templateId=%s"
URL_ALLDAY = "http://127.0.0.1:6000/ysten-lvoms-epg/epg/getAllDayPrograms.shtml?uuid=%s&templateId=%s"

F_UUID = open("/tmp/Monitor/apidata/uuiddiff", 'w')
F_ALLDAY = open("/tmp/Monitor/apidata/alldaydiff", 'w')

TTIME = time.strftime("%Y%m%d", time.localtime(time.time()))


def alldayverify(uuid, template):
    url_allday = URL_ALLDAY % (uuid, template)
    try:
        response = urllib2.urlopen(url_allday, timeout=1)
    except urllib2.URLError:
        print >>F_ALLDAY, 0
        return 0  # 退出当前循环
    else:
        data = json.load(response)
        if len(data) != 0:
            otime = time.strftime("%Y%m%d", time.localtime(float(data[0]['playDate'])))
            if otime >= TTIME:  #  有发现个别uuid有明天的节目单 考虑下23:30的节目单
                #  取第一个节目单的开始时间到当前节目单的结束时间
                alltime = data[0]['programs']
                futuret = []
                nowt = []
                replayt = []
                for i in alltime:
                    if i['urlType'] == 'none':
                        futuret.append(i['endTime'])
                        futuret.append(i['startTime'])
                    if i['urlType'] == 'play':
                        nowt.append(i['endTime'])
                    if i['urlType'] == 'replay':
                        replayt.append(i['endTime'])
                        replayt.append(i['startTime'])
                if len(nowt) == 0:
                    for i in data[1]['programs']:  # 23:30的直播信息在data[1]
                        if i['urlType'] == 'play':
                            nowt.append(i['endTime'])
                if len(futuret) < 4:  # data[0]为明天的节目单，且只有一个预加载节目单, 另一个节目单在今天data[1] 0286 SD-1500k-576P-scchengdu4
                    for i in data[1]['programs']:
                        if i['urlType'] == 'none':
                            futuret.append(i['endTime'])
                            futuret.append(i['startTime'])
                if len(nowt) == 0:  # 判断是否有直播节目单信息
                    print >> F_ALLDAY, "%s %s programs now miss" % (template, uuid)
                    return 1  # 没有当前直播节目单信息则退出
                if len(futuret) == 0:  # 判断是否预加载节目单
                    print >>F_ALLDAY, "%s %s programs future miss" % (template, uuid)
                elif len(futuret) == 2:  # 判断预加载一个节目单
                    print >> F_ALLDAY, "%s %s programs future less" % (template, uuid)
                elif nowt[0] == futuret[3] and futuret[2] == futuret[1]:
                    print >>F_ALLDAY, "%s %s programs ok" % (template, uuid)
                else:
                    print >>F_ALLDAY, "%s %s programs disorder" % (template, uuid)
            else:
                print >>F_ALLDAY, "%s %s programs today miss" % (template, uuid)
        else:
            print >> F_ALLDAY, "%s %s programs null" % (template, uuid)


def uuidverify(template):
    #  print 'thread %s %s is running...' % (threading.current_thread().name, template)
    conn = sqlite3.connect('/data/tmp/wtv.db')
    c = conn.cursor()
    url_uuid = URL_UUID % template
    try:
        response = urllib2.urlopen(url_uuid, timeout=1)
    except urllib2.URLError:
        print >>F_UUID, 0
        return 0  # 退出当前循环
    else:
        data = json.load(response)
        default = c.execute("select uuid from w%s" % template).fetchall()
        online = []
        for item in data:
            online.append((item['uuid'],))
        difference = [i for i in default if i not in online]  # 底量数据与线上数据的差集
        if difference == []:
            print>>F_UUID, "%s template ok" % template
            for uuid in default:
                alldayverify(uuid[0], template)
        else:
            print>>F_UUID, template, difference
            for uuid in online:
                alldayverify(uuid[0], template)


if __name__ == '__main__':

    # conn = sqlite3.connect('/data/tmp/wtv.db')
    # c = conn.cursor()
    threads = []
    for template in TEMPLATES:
        threadt = threading.Thread(target=uuidverify, args=(template,), name='LoopThread')
        threads.append(threadt)
        # uuidverify(c, template)
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    F_UUID.flush()
    F_UUID.close()
    F_ALLDAY.flush()
    F_ALLDAY.close()
