#!/usr/local/easyops/python/bin/python
# encoding:utf-8
#########################################################################
# easyops public tools
# file_ver: 1.0.1
# create by weimi, 2016-8-13
# Copyright 2016 weimi
#
# 采集虚拟机与宿主机的关系（VM）
#########################################################################
import os, sys
_curPath = os.path.dirname(os.path.abspath(__file__))
_basePath = os.path.dirname(_curPath)
sys.path.insert(0, _curPath)
sys.path.insert(0, _basePath)

from pyVim.connect import SmartConnect, Disconnect

import atexit
import ssl

import collector_config, utils, report_to_cmdb

# key:host_ip value:host_instance_id
# host 缓存表
host_dict = {}

def get_host_instace_id(ip):
    if not host_dict.has_key(ip):
        host = utils.get_host_with_ip(ip)
        if host:
            host_dict[ip] = host['instanceId']
        else:
            host_dict[ip] = None
    return host_dict[ip]


def vm_host_re_with_macs_host_ip(macs, host_instance_id):
    if not host_instance_id:
        return
    for mac in macs:
        vm_host = utils.get_host_with_mac(mac)
        if not vm_host:
            continue
        report_to_cmdb.report_vm_host_host_re(vm_host, host_instance_id)

def vm_host_re_with_ip_host_ip(ip, host_instance_id):
    if not host_instance_id:
        return
    vm_host = utils.get_host_with_ip(ip)
    if not vm_host:
        return
    report_to_cmdb.report_vm_host_host_re(vm_host, host_instance_id)

def PrintVmInfo(vm, depth=1):
    maxdepth = 20
    if hasattr(vm, 'childEntity'):
        if depth > maxdepth:
            return
        vmList = vm.childEntity
        for c in vmList:
            PrintVmInfo(c, depth+1)
        return
    summary = vm.summary
    vm_ip = None
    try:
        host_ip = vm.runtime.host.name
    except Exception,e:
        # import pdb;pdb.set_trace()
        return
    host_instance_id = host_ip
    # host_instance_id = get_host_instace_id(host_ip)
    # if not host_instance_id:
    #     return
    if summary.guest != None:
       vm_ip = summary.guest.ipAddress

    if vm_ip == None or vm_ip == '':
        vm_host_mac_list = []
        for device in vm.config.hardware.device:
            if device.key == 4000:
                vm_host_mac_list.append(str(device.macAddress))
        vm_host_re_with_macs_host_ip(vm_host_mac_list, host_instance_id)
        return
    vm_host_re_with_ip_host_ip(vm_ip, host_instance_id)

def main():

    context = ssl.SSLContext(ssl.PROTOCOL_TLSv1)
    context.verify_mode = ssl.CERT_NONE

    vm_service = collector_config.vm_service

    si = SmartConnect(host=vm_service['host'],
                     user=vm_service['user'],
                     pwd=vm_service['pwd'],
                     port=int(vm_service['port']),
                     sslContext=context)
    if not si:
        utils.log_info(u"连接VSwitch失败")
        return -1

    atexit.register(Disconnect, si)

    content = si.RetrieveContent()
    for child in content.rootFolder.childEntity:
        if hasattr(child, 'vmFolder'):
            datacenter = child
            vmFolder = datacenter.vmFolder
            vmList = vmFolder.childEntity
            for vm in vmList:
                PrintVmInfo(vm)
    return 0

# Start program
if __name__ == "__main__":
    main()
