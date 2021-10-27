[TOC]

# oracle常用工具

sqlplus：oracle自带的命令行管理工具；
PLSQL Developer：图形化管理工具；
sqldeveloper：oracle的工具；
Toad：DBA使用较多，主要用于数据库管理；

## sqlplus

oracle的命令行管理工具，即便oracle实例未启动也可能通过该工具连接至数据库的监听。

sqlplus工具可通过安装oracle的客户端使得本机具有该命令工具，也可以安装服务端的软件包而不安装数据库实现软件包的安装；

连接其他主机上的数据库实例：

```
    shell> sqlplus admin/admin@10.168.3.30:1521/vlms
    shell> sqlplus sys/oracle@10.168.3.30:1521/vlms as sysdba
```

## PLSQL的安装

1. 下载并安装plsqldev
2. 下载instantclient-basic-windows后解压至指定目录
3. 在plsql的首选项的“连接”窗口设置OCI库目录“D:\PLSQL_OCI\instantclient_12_2\oci.dll”

plsql 14的注册信息：

product code: ke4tv8t5jtxz493kl8s2nn3t6xgngcmgf3
serial Number: 264452
password: xs374ca
