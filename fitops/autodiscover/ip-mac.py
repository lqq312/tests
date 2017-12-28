#!/usr/local/easyops/python/bin/python
# -*- coding: UTF-8 -*-
#!/usr/local/easyops/python/bin/python
# encoding:utf-8
#########################################################################
# easyops public tools
# file_ver: 1.0.1
# create by weimi, 2016-8-13
# Copyright 2016 weimi
#
# nmap扫描本机网段，发现本网段活跃IP-MAC关系
#########################################################################
import os, sys
_curPath = os.path.dirname(os.path.abspath(__file__))
_basePath = os.path.dirname(_curPath)
sys.path.insert(0, _curPath)
sys.path.insert(0, _basePath)

import nmap

import utils, report_to_cmdb, collector_config

def get_local_mac(local_ip):
    host = utils.get_host_with_ip(local_ip)
    if host:
        return host['_mac']
    return ''

def get_local_scope_ip_list(loacl_scope_pre):
    loacl_scope_pre = loacl_scope_pre + '.'
    params = {
        'name$reg' : loacl_scope_pre
    }
    return utils.search_instance_all(collector_config.ipaddr_id, params)

# 检查不活跃的IP
def check_un_active_ip(active_ip_dict, old_ip_list):
    un_active_ip_list = []
    for ip_dict in old_ip_list:
        ip = ip_dict['name']
        if not active_ip_dict.has_key(ip):
            un_active_ip_list.append(ip_dict)
    print "不活跃的IP:"
    for item in un_active_ip_list:
        print item['name']

# 检查新增的IP
def check_new_active_ip(active_ip_dict, old_ip_list):
    old_ip_dict = {}
    new_active_ip_list = []

    for ip_dict in old_ip_list:
        ip = ip_dict['name']
        old_ip_dict[ip] = 1

    for active_ip in active_ip_dict.keys():
        if not old_ip_dict.has_key(active_ip):
            new_active_ip_list.append({
                'ip': active_ip,
                'mac': active_ip_dict[active_ip]
            })
    print "新增的IP:"
    for item in new_active_ip_list:
        print item['ip']


def main():
    utils.append_report_json_path_to_sys()
    from report_json import get_localip_and_org
    local_ip, org = get_localip_and_org()
    loacl_scope_pre = ".".join(local_ip.split('.')[0:-1])
    local_scope = loacl_scope_pre + '.0/24'
    nm = nmap.PortScanner()
    result = nm.scan(hosts=local_scope, arguments='-sP')['scan']
    ip_mac_dict = {}
    ip_mac_dict[local_ip] = str(get_local_mac(local_ip))
    for key, value in result.items():
        if value['addresses'].has_key('mac'):
            ip_mac_dict[key] = utils.mac_format(value['addresses']['mac'])
        else:
            print 'not mac',key
    loacl_ip_list =  get_local_scope_ip_list(loacl_scope_pre)

    for item in loacl_ip_list:
        print item['name'], item['mac']

    # print ip_mac_dict
    check_new_active_ip(ip_mac_dict, loacl_ip_list)

    check_un_active_ip(ip_mac_dict, loacl_ip_list)



if __name__ == '__main__':
    main()

