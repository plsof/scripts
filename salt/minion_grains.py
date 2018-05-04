#!/usr/bin/env python
#-*- coding:utf-8 -*-
__author__ = "pdd"
__date__ = "20171029"

import salt.client
import xlsxwriter

local = salt.client.LocalClient()

# 获取salt客户端列表
def GetSaltMinionHostList():
    salt_minion_list = []
    with open("./minion_list", 'r') as f:
        for minion in f.readlines():
            tgt = minion.strip()
            if tgt == '':
                continue
            else:
                salt_minion_list.append(tgt)
    return salt_minion_list

# 执行salt.client获取grains
def MinionGrains():
    tgt = GetSaltMinionHostList()
    grains = local.cmd(tgt, 'grains.items', expr_form="list")
    return grains

# 提取信息写入excel
def GenerateXlsx():
    minion_grains = MinionGrains()

    cols = ['Minion_ID',
            'System_Version',
            'Network_IP',
            'MAC',
            'HostName',
            'CPU_Model',
            'CPU_Counts',
            'Mem_Total(MB)',
            'Disk_Total']

    workbook = xlsxwriter.Workbook('/tmp/minioninfo.xlsx')
    worksheet = workbook.add_worksheet()
    worksheet.write_row('A1', cols)
    row = 1
    col = 0

    for minion,grain in minion_grains.items():
        Minion_ID = minion
        System_Version = grain['osfullname'] + " " + \
                         grain['osrelease'] + " " + \
                         grain['osarch']
        IPaddrs = grain['ip4_interfaces']
        card_ip = []
        for network_card, ipaddr in IPaddrs.items():
            if network_card == 'lo':
                continue
            else:
                if not ipaddr:
                    ipaddr = " no ipaddr"
                    card_ip.append(network_card + " " + ipaddr + "\n")
                else:
                    card_ip.append(network_card + " " + " ".join(ipaddr) + "\n")
        Network_IP = "".join(card_ip).strip()
        MAC = (grain['hwaddr_interfaces'])
        card_mac = []
        for network_card, mac in MAC.items():
            if network_card == 'lo':
                continue
            else:
                card_mac.append(network_card + " " + "".join(mac) + "\n")
        MAC = "".join(card_mac).strip()
        HostName = grain['host']
        CPU_Model = grain['cpu_model']
        CPU_Counts = grain['num_cpus']
        Mem_Total = int(grain['mem_total'])
        Disk_total = local.cmd(minion, 'cmd.run', ['df -Th'])[minion]

        line = [str(Minion_ID),
                str(System_Version),
                str(Network_IP),
                str(MAC),
                str(HostName),
                str(CPU_Model),
                str(CPU_Counts),
                str(Mem_Total),
                str(Disk_total)]

        for j in line:
            worksheet.write(row, col,     j)
            col+=1
        row += 1
        col = 0

if __name__ == "__main__":
    GenerateXlsx()
