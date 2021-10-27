[TOC]

# oracle的控制文件

控制文件是一个很小的二进制文件，用于记录数据库的物理结构。一个控制文件只属于一个数据库。当数据库的物理结构改变的时候，Oracle会更新控制文件（例如增加文件）。用户不能编辑控制文件，控制文件的修改为Oracle完成。

官方文档：Concepts --> 11.3 Overview of Control Files

查看数据库的控制文件的路径：

```
    SQL> show parameter control_files
        NAME                                 TYPE        VALUE
        ------------------------------------ ----------- ------------------------------
        control_files                        string      /u01/app/oracle/oradata/vlms/c
                                                         ontrol01.ctl, /u01/app/oracle/
                                                         fast_recovery_area/vlms/contro
                                                         l02.ctl
```

## 控制文件的内容

* 数据库名
* 数据库创建的时间戳
* 数据库文件、重做日志、归档日志路径
* 表空间信息
* RMAN备份信息

## 控制文件的作用

1. 控制文件含有数据文件、redo日志文件等位置信息，数据库启动会用到这个信息。当数据库增加、重命名、删除文件会更新控制文件；
2. 包含一些元数据，在数据库open之前。控制文件里面包含有检查点checkpoint信息，当数据库需要恢复时需要这个信息。每三秒检查点进程CKPT会记录检查点到控制文件。
3. 至少有1份，一般都是2份以上，完全相同。同时打开。
4. 可以避免单点故障；
5. 控制文件在多个磁盘的放置。

查看检查点进程：

```
    shell> ps -ef | grep ora_ckpt
        oracle    6326 28079  0 13:18 pts/1    00:00:00 grep --color=auto ora_ckpt
        oracle   16390     1  0 11:31 ?        00:00:02 ora_ckpt_vlms
```

## 控制文件结构

由section组成，每个section由多个记录record组成；

```
    # 通过以下命令将控制文件的内容dump出来，用于查看其具体内容
    # level 1的级别内容较少，如设置为level 3则内容会相应增多
    SQL> alter session set events 'immediate trace name controlf level 1';
    SQL> select * from v$diag_info;
        ......
        ---------- ----------------------------------------------------------------
        VALUE
        --------------------------------------------------------------------------------
            CON_ID
        ----------
                 1 Health Monitor
        /u01/app/oracle/diag/rdbms/vlms/vlms/hm
                 0

                 1 Default Trace File
        /u01/app/oracle/diag/rdbms/vlms/vlms/trace/vlms_ora_16844.trc
                 0
        ......
    SQL> exit
    shell> cat /u01/app/oracle/diag/rdbms/vlms/vlms/trace/vlms_ora_16844.trc
        Trace file /u01/app/oracle/diag/rdbms/vlms/vlms/trace/vlms_ora_16844.trc
        Oracle Database 12c Enterprise Edition Release 12.2.0.1.0 - 64bit Production
        Build label:    RDBMS_12.2.0.1.0_LINUX.X64_170125
        ORACLE_HOME:    /u01/app/oracle/product/12.2.0/dbhome_1
        System name:    Linux
        Node name:      oracle
        Release:        3.10.0-1160.el7.x86_64
        Version:        #1 SMP Mon Oct 19 16:18:59 UTC 2020
        Machine:        x86_64
        Instance name: vlms
        Redo thread mounted by this instance: 1
        Oracle process number: 60
        Unix process pid: 16844, image: oracle@oracle (TNS V1-V3)


        *** 2021-08-26T13:42:19.434879+08:00
        *** SESSION ID:(12.23337) 2021-08-26T13:42:19.434926+08:00
        *** CLIENT ID:() 2021-08-26T13:42:19.434937+08:00
        *** SERVICE NAME:(SYS$USERS) 2021-08-26T13:42:19.434949+08:00
        *** MODULE NAME:(sqlplus@oracle (TNS V1-V3)) 2021-08-26T13:42:19.434960+08:00
        *** ACTION NAME:() 2021-08-26T13:42:19.434971+08:00
        *** CLIENT DRIVER:(SQL*PLUS) 2021-08-26T13:42:19.434981+08:00

        DUMP OF CONTROL FILES, Seq # 1292 = 0x50c
         V10 STYLE FILE HEADER:
                Compatibility Vsn = 203423744=0xc200000
                Db ID=785808808=0x2ed67da8, Db Name='VLMS'
                Activation ID=0=0x0
                Control Seq=1292=0x50c, File size=646=0x286
                File Number=0, Blksiz=16384, File Type=1 CONTROL
        *** END OF DUMP ***
```


控制文件的记录分为两种类型：

* 循环重用记录
    - 这些记录包含可以被覆盖的非关键信息。当所有可用的记录槽用完时，数据库需要扩展控制文件或覆盖最旧的记录，以便为新记录腾出空间。循环重用记录可以删除，并且不会影响数据库运行，如：RMAN备份记录，归档日志历史信息等内容。
* 非循环重用记录
    - 这些记录包含不经常更改且不能被覆盖的关键信息。包括表空间、数据文件、联机重做日志文件、redo线程。oracle数据库绝不会重用这些记录，除非从表空间中删除相应的对象。

# 相关视图和参数

control_file_record_keep_time：定义了控制文件中循环重用记录中最小存放的时长，单位为天；

```
    SQL> show parameter control_file_record_keep_time

        NAME                                 TYPE        VALUE
        ------------------------------------ ----------- ------------------------------
        control_file_record_keep_time        integer     7
```

v$controlfile：控制文件的位置信息、大小、数量；

v$controlfile_record_section：显示有关控制文件记录部分的信息；

## 增加/删除一个控制文件

除了通过oracle的管理命令进行修改也可以通过修改pfile，从pfile重新生成spfile的方式增加或删除一个控制文件。

### 增加一个控制文件

```
    SQL> show parameter control_files

        NAME                                 TYPE        VALUE
        ------------------------------------ ----------- ------------------------------
        control_files                        string      /u01/app/oracle/oradata/vlms/c
                                                         ontrol01.ctl, /u01/app/oracle/
                                                         fast_recovery_area/vlms/contro
                                                         l02.ctl
    SQL> alter system set control_files='/u01/app/oracle/oradata/vlms/control01.ctl','/u01/app/oracle/oradata/vlms/control02.ctl','/u01/app/oracle/fast_recovery_area/vlms/control02.ctl' scope=spfile;

        System altered.
    SQL> shutdown immediate;
        Database closed.
        Database dismounted.
        ORACLE instance shut down.
    SQL> exit
    shell> cd /u01/app/oracle/oradata/vlms/
    shell> cp control01.ctl control02.ctl
    shell> sqlplus / as sysdba
    SQL> starup
    SQL> show parameter control_files

        NAME                                 TYPE        VALUE
        ------------------------------------ ----------- ------------------------------
        control_files                        string      /u01/app/oracle/oradata/vlms/c
                                                         ontrol01.ctl, /u01/app/oracle/
                                                         oradata/vlms/control02.ctl, /u
                                                         01/app/oracle/fast_recovery_ar
                                                         ea/vlms/control02.ctl
```


### 删除一个控制文件

```
    SQL> show parameter control_files

        NAME                                 TYPE        VALUE
        ------------------------------------ ----------- ------------------------------
        control_files                        string      /u01/app/oracle/oradata/vlms/c
                                                         ontrol01.ctl, /u01/app/oracle/
                                                         oradata/vlms/control02.ctl, /u
                                                         01/app/oracle/fast_recovery_ar
                                                         ea/vlms/control02.ctl
    SQL> alter system set control_files='/u01/app/oracle/oradata/vlms/control01.ctl','/u01/app/oracle/fast_recovery_area/vlms/control02.ctl' scope=spfile;

        System altered.
    SQL> shutdown immediate;
    shell> rm /u01/app/oracle/oradata/vlms/control02.ctl
    SQL> show parameter control_files;
```

## 清理控制文件中的记录

1. 通过重建控制文件（一般不建议这样操作）或设置control_file_record_keep_time=0（`alter system set control_file_record_keep_time=0;`）。
2. 使用execute sys.dbms_backup_resotre.resetCfileSection来清理具体某部分的记录。

* 清理v$log_history对应的记录
    - `execute sys.dbms_backup_restore_resetCfileSection(9);`
* 清理v$archived_log对应的记录
    - `execute sys.dbms_backup_restore.resetCfileSection(11);`
* 清理v$rman_status对应的记录
    - `execute sys.dbms_backup_restore.resetCfileSection(28);`
* 清理rman备份信息
    - `execute sys.dbms_backup_restore.resetCfileSection(12);`
