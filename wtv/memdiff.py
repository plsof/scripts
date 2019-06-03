#!/usr/bin/env python
# -*- coding:utf8 -*-

import time
import json
import sqlite3
import urllib2

# TEMPLATES = ['0281', '0282', '0283', '02838', '0284', '02861', '0285', '02862', '02837', '02860', '0286', '0287', '02836', '0288', '02832', '02833', '02831', '02830', '02827', '0289', '0290', '02858', '02826', '02857', '02825', '0291', '02824', '02856', '0292', '02823', '02855', '0293', '02822', '02854', '0294', '02821', '02853', '0295', '02820', '02851', '0296', '02818', '02813', '02852', '02812', '66666', '02811', '0297', '02850', '02810', '02849', '02848', '02828', '02847', '02846', '02829', '02843', '02814', '02842', '02815', '02841', '02840', '02839', '88884', '02859', '02863', '02801', '02802', '02803', '02804', '02805', '02806', '02844', '0790']
TEMPLATES = ['0282', '0283', '0286', '0290', '0297', '02810', '02814', '02815', '02830', '02831', '02838', '02840', '02850']

URL_UUID = "http://127.0.0.1:6000/ysten-lvoms-epg/epg/getChannels.shtml?templateId=%s"
URL_ALLDAY = "http://127.0.0.1:6000/ysten-lvoms-epg/epg/getAllDayPrograms.shtml?uuid=%s&templateId=%s"

F_UUID = open("/tmp/Monitor/apidata/uuiddiff", 'w')
F_ALLDAY = open("/tmp/Monitor/apidata/alldaydiff", 'w')

# 获取今天的日期
TTIME = time.strftime("%Y%m%d", time.localtime(time.time()))


def alldayverify(uuid, template):
    url_allday = URL_ALLDAY % (uuid, template)
    try:
        response = urllib2.urlopen(url_allday, timeout=1)
    except urllib2.URLError:
        print >>F_ALLDAY, 0
        return 1  # 退出当前template循环
    else:
        data = json.load(response)
        if len(data) != 0:
            otime = time.strftime("%Y%m%d", time.localtime(float(data[0]['playDate'])))
            if otime >= TTIME:  # data[0]有时候是明天的节目单信息，考虑下23:30的data[0],data[1]
                alltime = data[0]['programs']
                futuret = []
                nfuturet = []
                nowt = []
                # replayt = []
                for i in alltime:
                    if i['urlType'] == 'none':
                        futuret.append(i['endTime'])
                        futuret.append(i['startTime'])
                    if i['urlType'] == 'play':
                        nowt.append(i['endTime'])
                    # if i['urlType'] == 'replay':
                    #     replayt.append(i['endTime'])
                    #     replayt.append(i['startTime'])
                if len(nowt) == 0:  # data[0]为明天的节目单，且只有一个预加载节目单, 另一个节目单在今天data[1] 0286 SD-1500k-576P-scchengdu4
                    for i in data[1]['programs']:  # 23:30的直播信息在data[1], 第一个预加载节目单可能也在。
                        if i['urlType'] == 'none':
                            futuret.append(i['endTime'])
                            futuret.append(i['startTime'])
                        if i['urlType'] == 'play':
                            nowt.append(i['endTime'])
                if len(nowt) == 0:  # 判断是否有直播节目单
                    print >> F_ALLDAY, "%s %s programs now miss" % (template, uuid)
                    return 1  # 没有直播节目单则退出当前uuid循环
                nfuturet = [x for x in futuret if x >= nowt[0]]  # 判断黑莓replay tag为空
                if len(nfuturet) == 0:  # 判断是否有预加载节目单
                    print >>F_ALLDAY, "%s %s programs future miss" % (template, uuid)
                elif len(nfuturet) == 2:  # 判断预加载一个节目单
                    print >> F_ALLDAY, "%s %s programs future less" % (template, uuid)
                elif nowt[0] == nfuturet[-1] and nfuturet[-2] == nfuturet[-3]:
                    print >>F_ALLDAY, "%s %s programs ok" % (template, uuid)
                elif nowt[0] < nfuturet[-1] or nfuturet[-2] < nfuturet[-3]:
                    print >>F_ALLDAY, "%s %s programs future uncontinuity" % (template, uuid)  # 节目单时间不连续
                else:
                    # print >>F_ALLDAY, "%s %s programs future overlap" % (template, uuid)  # 节目单时间有重叠
                    pass
            else:
                print >>F_ALLDAY, "%s %s programs today miss" % (template, uuid)
        else:
            print >> F_ALLDAY, "%s %s programs null" % (template, uuid)


def uuidverify(c, template):
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
            for uuid in [i for i in default if i in online]:
                alldayverify(uuid[0], template)


if __name__ == '__main__':

    conn = sqlite3.connect('/data/tmp/wtv.db')
    c = conn.cursor()
    for template in TEMPLATES:
        uuidverify(c, template)
    F_UUID.flush()
    F_UUID.close()
    F_ALLDAY.flush()
    F_ALLDAY.close()
