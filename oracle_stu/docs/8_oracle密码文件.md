[TOC]

# 密码文件

官方文档：Administrator's Guide --> 1.7 Creating and Maintaining a Database Password File;

密码文件路径：

* Linux：${ORACLE_HOME}/dbs/orapwSID
* Windows：${ORACLE_HOME}\database\PWDORACLE_SID.ora

密码文件用于具有sysdba身份的用户执行远程登陆数据库，Oracle允许用户通过密码文件验证，在数据库未启动之前登录，从而启动实例，加载打开数据库；

* remote_login_passwordfile：指定具有sysdba权限的用户使用哪种方式来验证身份，该参数为静态参数；

```
    # 查看与远程相关的参数
    SQL> show parameter remote;

        NAME                                 TYPE        VALUE
        ------------------------------------ ----------- ------------------------------
        remote_dependencies_mode             string      TIMESTAMP
        remote_listener                      string
        remote_login_passwordfile            string      EXCLUSIVE
        remote_os_authent                    boolean     FALSE
        remote_os_roles                      boolean     FALSE
        remote_recovery_file_dest            string
        result_cache_remote_expiration       integer     0
```

查看具有sysdba权限的用户有哪些：

```
    SQL> select * from v$pwfile_users;
    SQL> select * from v$pwfile_users where sysdba='TRUE';
```

# 修改密码

方法一：

```
    shell> sqlplus / as sysdba
    SQL> alter user sys identified by XXX;
```

方法二：

```
    shell> orapwd file=orapwvlms password=XXX force=y
```