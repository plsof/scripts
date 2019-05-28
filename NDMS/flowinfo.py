#!/usr/bin/env python3
# -*- coding:utf8 -*-

import json
import urllib.request


def info(url):
    try:
        response = urllib.request.urlopen(url, timeout=5)

    except urllib.error.URLErrror:
        print("url timeout")  # 接口超时
        return  # 退出
    else:
        datas = json.loads(response.read())
        if datas == []:
            print("response null")
        else:
            for data in datas['data']:
                print("=====================Flow==============================")
                for flow in data['flowData']:
                    print("-------------------Topic-------------------------------")
                    print("topicId: ", flow['topicId'])
                    print("title: ", flow['title'])
                    print("desktopId: ", flow['desktopId'])
                    print("flowId: ", flow['flowId'])
                    print("dataType: ", flow['dataType'])
                    print("recType: ", flow['recType'])
                    for item in flow['items']:
                        print("\titemId: ", item['itemId'])
                        print("\ttitle: ", item['title'])
                        print("\tcontentType: ", item['contentType'])
                        for content in item['contents']:
                            print("\t\tcontentId: ", content['contentId'])
                            print("\t\ttitle: ", content['title'])
                            print("\t\tcontentImage: ", content['contentImage'])
                            print("\t\tactionType: ", content['actionType'])
                            print("\t\tactionUrl: ", content['actionUrl'])


if __name__ == "__main__":

    # personal
    URL = 'http://ndmsapi.taipan.jsa.bcs.ottcn.com:8082/ndms-api/findFlowInfo.json?uid=54069842&abilityString=%257B%2522abilities%2522%253A%255B%2522NxM%2522%252C%2522timeShift%2522%252C%25224K-1%257Ccp-TENCENT%2522%255D%252C%2522businessGroupIds%2522%253A%255B%255D%252C%2522deviceGroupIds%2522%253A%255B%25221697%2522%255D%252C%2522districtCode%2522%253A%2522320100%2522%252C%2522upgradeUserGroupIds%2522%253A%255B%255D%252C%2522userGroupIds%2522%253A%255B%2522221%2522%255D%257D&flowType=personal&pageCount=100&isCache=&pageStart=1&deviceMac=0c%3Ac6%3A55%3Aac%3Aa1%3A83&portrait=&flowId=662509520135651328'
    # common 1
    #URL = 'http://ndmsapi.taipan.jsa.bcs.ottcn.com:8082/ndms-api/findFlowInfo.json?uid=54069842%2C54069842%2C54069842&abilityString=%257B%2522deviceGroupIds%2522%253A%255B%25221697%2522%255D%252C%2522userGroupIds%2522%253A%255B%255D%252C%2522districtCode%2522%253A%2522%2522%252C%2522abilities%2522%253A%255B%2522NxM%2522%252C%2522timeShift%2522%252C%25224K-1%257Ccp-TENCENT%2522%255D%252C%2522businessGroupIds%2522%253A%255B%255D%257D&flowType=common%2Ccommon%2Ccommon&pageCount=100&isCache=0&pageStart=1&deviceMac=0c%3Ac6%3A55%3Aac%3Aa1%3A83&portrait=&flowId=662464904015380480%2C668260103387873280%2C662497700385652736'
    # common 2
    #URL = 'http://ndmsapi.taipan.jsa.bcs.ottcn.com:8082/ndms-api/findFlowInfo.json?uid=54069842%2C54069842%2C54069842%2C54069842%2C54069842%2C54069842&abilityString=%257B%2522abilities%2522%253A%255B%2522NxM%2522%252C%2522timeShift%2522%252C%25224K-1%257Ccp-TENCENT%2522%255D%252C%2522businessGroupIds%2522%253A%255B%255D%252C%2522deviceGroupIds%2522%253A%255B%25221697%2522%255D%252C%2522districtCode%2522%253A%2522320100%2522%252C%2522upgradeUserGroupIds%2522%253A%255B%255D%252C%2522userGroupIds%2522%253A%255B%2522221%2522%255D%257D&flowType=common%2Ccommon%2Ccommon%2Ccommon%2Ccommon%2Ccommon&pageCount=100&isCache=0&pageStart=1&deviceMac=0c%3Ac6%3A55%3Aac%3Aa1%3A83&portrait=&flowId=662506711227039744%2C680288193660059648%2C662507029054619648%2C662507243802984448%2C662507432781545472%2C662507638939975680'
    # common 3
    # URL = 'http://ndmsapi.taipan.jsa.bcs.ottcn.com:8082/ndms-api/findFlowInfo.json?uid=54069842%2C54069842&abilityString=%257B%2522abilities%2522%253A%255B%2522NxM%2522%252C%2522timeShift%2522%252C%25224K-1%257Ccp-TENCENT%2522%255D%252C%2522businessGroupIds%2522%253A%255B%255D%252C%2522deviceGroupIds%2522%253A%255B%25221697%2522%255D%252C%2522districtCode%2522%253A%2522320100%2522%252C%2522upgradeUserGroupIds%2522%253A%255B%255D%252C%2522userGroupIds%2522%253A%255B%2522221%2522%255D%257D&flowType=common%2Ccommon&pageCount=100&isCache=0&pageStart=1&deviceMac=0c%3Ac6%3A55%3Aac%3Aa1%3A83&portrait=&flowId=662507810738667520%2C662508025487032320'
    info(URL)
