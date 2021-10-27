[TOC]

# 软件包下载

# 调整Linux系统参数

1. 检查硬件环境
    * 内存需求
        - 自动存储管理（AMM，Automatic Memory Management）需要共享内存和文件描述符；
        - 共享内存即/dev/shm，该值应该比系统内存小，应该比MEMORY_MAX_TARGET和MEMORY_TARGET大；
        - 在/etc/fstab中设置“tmpfs /dev/shm tmpfs defaults,size=4g 0 0”，然后执行`mount -o remount /dev/shm`即可生效；
2. 检查系统架构
    * 检查系统架构和操作系统版本

    ```
    shell> uname -a
    shell> uname -m
    shell> cat /etc/redaht-release
    ```

3. 创建用户和组

    ```
    shell> groupadd oinstall
    shell> groupadd dba
    shell> useradd -g oinstall -G dba oracle
    shell> passwd oracle
    ```

4. 配置内核参数
    ```
    shell> vim /etc/sysctl.d/97-oracledatabase-sysctl.conf
        fs.aio-max-nr=1048576
        fs.file-max=6815744
        # kernel.shmmax设置为物理内存的90%即可（最好能比MEMORY_TARGET大），可取的最大值为物理内存值 -1byte（12G物理内存，该值应该设置为12*1024*1024*1024 -1）
        kernel.shmmax=7517682892
        # 可以使用的共享内存的总页数，将kernel.shmmax的值除以4
        kernel.shmall=1879420723
        kernel.shmmni=4096
        kernel.sem=250 32000 100 128
        net.ipv4.ip_local_port_range=9000 65500
        net.core.rmem_default=262144
        net.core.rmem_max=4194304
        net.core.wmem_default=262144
        net.core.wmem_max=1048576
    shell> sysctl --system
    shell> sysctl -a | grep shmmax
    shell> sysctl -a | grep shmall
    ```

5. 配置资源限制

    ```
    shell> vim /etc/security/limits.conf
        oracle soft nproc 2047
        oracle hard nproc 16384
        oracle soft nofile 1024
        oracle hard nofile 65536
        oracle soft stack 3145728
        oracle hard stack 3145728
    ```

6. 创建数据目录

    ```
    shell> mkdir -pv /u01/app/oracle/product/12.2.0/dbhome_1
    shell> chown -R oracle.oinstall /u01
    shell> chmod -R 775 /u01
    ```

7. 设置环境变量

    ```
    shell> su - oracle
    shell> vim ~/.bash_profile
        export ORACLE_SID=vms3devdb
        export ORACLE_BASE=/u01/app/oracle
        export ORACLE_HOME=${ORACLE_BASE}/product/12.2.0/dbhome_1
        export PATH=${ORACLE_HOME}/bin:${PATH}
    ```

8. 修改/etc/hosts

    ```
    shell> hostname
    shell> vim /etc/hosts
        xxx.xxx.xxx.xxx AAA AAA
    ```

9. 关闭SELinux

    ```
    shell> vim /etc/selinux
        SELINUX=disabled
    shell> setenforce 0
    shell> getenforce
    ```

10. 关闭防火墙

    ```
    shell> systemctl stop firewalld
    shell> systemctl disable firewalld
    ```

11. 关闭透明大页

    ```
    shell> cat /sys/kernel/mm/transparent_hugepage/enabled
        [always]表示启用
        [never]表示禁用
    shell> vim /etc/default/grub
        GRUB_CMDLINE_LINUX="crashkernel=auto rhgb quiet transparent_hugepage=never"
    shell> grub2-mkconfig -o /boot/grub2/grub.cfg
    shell> systemctl reboot
    shell> cat /proc/cmdline
    ```

12. 解决依赖关系

    ```
    shell> yum -y install binutils compat-libcap1-1.10 libgcc libstdc++  libstdc++-devel sysstat  gcc-c++ ksh make glibc glibc-devel libaio libaio-devel smartmontools net-tools
    ```

13. 调整swap分区

    oracle建议当RAM为1~2GB时，swap大小应该为RAM的1.5倍，当RAM为2~16GB时，swap应该与RAM大小相等，当RAM大于16GB时，swap应该为16G；

    ```
    shell> mkdir /opt/swap_files
    shell> dd if=/dev/zero of=/opt/swap_files/swap_file01 bs=1GB count=5
    shell> chmod 600 /opt/swap_files/swap_file01
    shell> mkswap /opt/swap_files/swap_file01
    shell> echo "/opt/swap_files/swap_file01 swap swap defaults 0 0" >> /etc/fstab
    shell> swapon -a
    ```

14. 编辑安装数据库实例的respons文件

    ```
    shell> vim /u01/database/response/db_install.rsp
        # 30行
        oracle.install.option=INSTALL_DB_AND_CONFIG
        # 35行
        UNIX_GROUP_NAME=oinstall
        # 42行
        INVENTORY_LOCATION=/u01/app/oraInventory
        # 46行
        ORACLE_HOME=/u01/app/oracle/product/12.2.0/dbhome_1
        # 51行
        ORACLE_BASE=/u01/app/oracle
        # 63行
        oracle.install.db.InstallEdition=EE
        # 80行
        oracle.install.db.OSDBA_GROUP=dba
        # 86行
        oracle.install.db.OSOPER_GROUP=dba
        # 91行
        oracle.install.db.OSBACKUPDBA_GROUP=dba
        # 96行
        oracle.install.db.OSDGDBA_GROUP=dba
        # 101行
        oracle.install.db.OSKMDBA_GROUP=dba
        # 106行
        oracle.install.db.OSRACDBA_GROUP=dba
        # 180行
        oracle.install.db.config.starterdb.type=GENERAL_PURPOSE
        # 185行
        oracle.install.db.config.starterdb.globalDBName=vms3devdb
        # 190行
        oracle.install.db.config.starterdb.SID=vms3devdb
        # 197行
        oracle.install.db.ConfigureAsContainerDB=false
        # 216行
        oracle.install.db.config.starterdb.characterSet=ZHS16GBK
        # 232行
        oracle.install.db.config.starterdb.memoryLimit=512
        # 259行
        oracle.install.db.config.starterdb.password.ALL=oracle
        # 334行
        oracle.install.db.config.starterdb.storageType=FILE_SYSTEM_STORAGE
        # 342行
        oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=/u01/app/oracle/oradata
        # 398行
        DECLINE_SECURITY_UPDATES=true
    shell> su - oracle
    shell> /u01/database/runInstaller -force -silent -noconfig -responseFile /u01/database/response/db_install.rsp
    shell> exit
    shell> /u01/app/oraInventory/orainstRoot.sh
    shell> /u01/app/oracle/product/12.2.0/dbhome_1/root.sh
    ```

15. 静默配置监听器

    ```
    shell> su - oracle
    shell> netca -silent -responsefile /u01/database/response/netca.rsp
    shell> ss -tunlp | grep 1521
    ```

16. 静默创建数据库

    ```
    shell> su - oracle
    shell> vim /u01/database/response/dbca.rsp
        # 32
        gdbName=vms3devdb
        # 42
        sid=vms3devdb
        # 52
        databaseConfigType=SI
        # 74
        policyManaged=false
        # 88
        createServerPool=false
        # 127
        force=false
        # 162
        createAsContainerDatabase=false
        # 223
        templateName=/u01/app/oracle/product/12.2.0/dbhome_1/assistants/dbca/templates/General_Purpose.dbc
        # 233
        sysPassword=oracle
        # 243
        systemPassword=oracle
        # 252
        oracleHomeUserPassword=oracle
        # 284
        runCVUChecks=false
        # 313
        omsPort=0
        # 341
        dvConfiguration=false
        # 391
        olsConfiguration=false
        # 401
        datafileJarLocation={ORACLE_HOME}/assistants/dbca/templates/
        # 411
        datafileDestination={ORACLE_BASE}/oradata/{DB_UNIQUE_NAME}/
        # 421
        recoveryAreaDestination={ORACLE_BASE}/fast_recovery_area/{DB_UNIQUE_NAME}
        # 431
        storageType=FS
        # 468
        characterSet=ZHS16GBK
        # 478
        nationalCharacterSet=UTF8
        # 488
        registerWithDirService=false
        # 526
        listeners=LISTENER
        # 546
        variables=DB_UNIQUE_NAME=vms3devdb,ORACLE_BASE=/u01/app/oracle,PDB_NAME=,DB_NAME=vms3devdb,ORACLE_HOME=/u01/app/oracle/product/12.2.0/dbhome_1,SID=vms3devdb
        # 555
        initParams=undo_tablespace=UNDOTBS1,memory_target=796MB,processes=300,db_recovery_file_dest_size=2780MB,nls_language=AMERICAN,dispatchers=(PROTOCOL=TCP) (SERVICE=vms3devdb),db_recovery_file_dest={ORACLE_BASE}/fast_recovery_area/{DB_UNIQUE_NAME},db_block_size=8192BYTES,diagnostic_dest={ORACLE_BASE},audit_file_dest={ORACLE_BASE}/admin/{DB_UNIQUE_NAME}/adump,nls_territory=AMERICA,local_listener=LISTENER_CDB1,compatible=12.2.0,control_files=("{ORACLE_BASE}/oradata/{DB_UNIQUE_NAME}/control01.ctl", "{ORACLE_BASE}/fast_recovery_area/{DB_UNIQUE_NAME}/control02.ctl"),db_name=vms3devdb,audit_trail=db,remote_login_passwordfile=EXCLUSIVE,open_cursors=300
        # 565
        sampleSchema=false
        # 574
        memoryPercentage=40
        # 584
        databaseType=MULTIPURPOSE
        # 594
        automaticMemoryManagement=false
        # 604
        totalMemory=0
    shell> dbca -silent -createDatabase -responseFile ./dbca.rsp
    ```

17. 设置oracle数据库开机自启动

    ```
    shell> su - oracle
    shell> which dbstart
        /u01/app/oracle/product/12.2.0/dbhome_1/bin/dbstart
    shell> vim /u01/app/oracle/product/12.2.0/dbhome_1/bin/dbstart
        # 修改第80行
        ORACLE_HOME_LISTNER=${ORACLE_HOME}
    shell> vim /u01/app/oracle/product/12.2.0/dbhome_1/bin/dbshut
        # 修改第50行
        ORACLE_HOME_LISTNER=${ORACLE_HOME}
    shell> vim /etc/oratab
        vms3devdb:/u01/app/oracle/product/12.2.0/dbhome_1:Y
    # 测试dbshut和dbstart是不正常
    shell> dbshut
        Processing Database instance "vms3devdb": log file /u01/app/oracle/product/12.2.0/dbhome_1/shutdown.log
    shell> sqlplus / as sysdba
    SQL> select status from v$instance;
        select status from v$instance
        *
        ERROR at line 1:
        ORA-01034: ORACLE not available
        Process ID: 0
        Session ID: 0 Serial number: 0
    SQL> exit
    shell> dbstart
        Processing Database instance "vms3devdb": log file /u01/app/oracle/product/12.2.0/dbhome_1/startup.log
    shell> sqlplus / as sysdba
    SQL> select status from v$instance;

        STATUS
        ------------
        OPEN
    SQL> exit
    shell> exit
    shell> vim /etc/rc.d/rc.local
        su oracle -lc  "/home/oracle/database/product/12c/db_1/bin/lsnrctl start"
        su oracle -lc  /home/oracle/database/product/12c/db_1/bin/dbstart
    shell> chmod +x /etc/rc.d/rc.local
    shell> systemctl reboot
    ```








