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
# 激活网段所有IP（nmap所有网段） 
#########################################################################
import os, sys
_curPath = os.path.dirname(os.path.abspath(__file__))
_basePath = os.path.dirname(_curPath)
sys.path.insert(0, _curPath)
sys.path.insert(0, _basePath)

import nmap

import utils, collector_config
import ip_tool


def scanner_ip_scope(ip_scope):
    start_ip = ip_scope['startip']
    mask = str(ip_tool.net_mask_to_int(ip_scope['mask']))
    try:
        nm = nmap.PortScanner()
        hosts = start_ip + '/' + mask
        nm.scan(hosts=hosts, arguments='-sP')
    except Exception, e:
        print e
def main():
    utils.enum_cmdb_instances(collector_config.ipscope_id, scanner_ip_scope)

if __name__ == '__main__':
    main()


