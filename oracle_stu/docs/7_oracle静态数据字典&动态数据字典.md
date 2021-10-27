[TOC]

# 静态数据字典

官方文档：Reference --> 2.1 About Static Data Dictionary Views

Oracle系统视图分两类：

* 静态数据字典；
* 动态性能视图；

静态数据字典中的视图分为三类，它们分别由三个前缀构成：

* user_*：存储了关于当前用户所拥有的对象的信息；
    - USER_TABLES：存储所有的用户表信息；
* all_*：存储了当前用户能够访问的对象的信息；
    - ALL_TABLES：当前用户能访问到的所有表；
* dba_*：存储了数据库中所有对象的信息；

查询所有的数据字典视图：`select * from dictionary;`

```
    # 查看USER_TABLES的字典描述信息
    SQL> select * from SYS.DICTIONARY t where t.TABLE_NAME='USER_TABLES';

    # 查看当前用户所拥有的表；
    SQL> select * from user_tables;

    ############################################################################

    # 查看ALL_TABLES的字典描述信息
    SQL> select * from SYS.DICTIONARY t where t.TABLE_NAME='ALL_TABLES';

    # 查看当前用户能访问的所有的表；
    SQL> select * from all_tables;
```

# 动态数据字典

官方文档：Reference --> 7.1 About Dynamic Performance Views

动态性能视图：当数据库运行的时候它们会不断进行更新，一般以v$开头，如：v$instance，v$sga，v$sesion等；

* v$xxx：本地实例动态性能视图；
* gv$xxx：全局动态性能视图（RAC环境下）

常见的动态视图：

* v$version：数据库版本信息；
* v$database：数据库相关信息；
* v$instance：实例相关信息；
* v$session：会话相关信息；
    - STATUS：表示会话的状态，其值为ACTIVE则表示会话为活动的，其值为INACTIVE则表示对应会话为非活动状态；
    - SID：该会话在系统内部的编号；
    - PORT：该会话的源端口，即客户端的端口号；
* v$tablespace：表空间相关信息（通过`select * from sys.dba_tablespaces;`也可查看表空间相关信息）；
* v$datafile\v$dbfile：数据文件相关信息（通过`select * from dba_data_files;`也可查看数据文件相关信息）；
* v$tempfile：临时文件相关信息；
* dba_tables：系统中所有的表；
* dba_temp_files：查看系统中所有的临时文件；
* dba_indexes：系统中所有的索引；
* dba_views：系统中所有的视图；
* v$log\v$logfile：重做日志相关信息；
* v$controlfile：控制文件相关信息；

根据SID和SERIAL#关闭某个会话：

```
    # SQL> alter system kill session 'SID,SERIAL#'
    SQL> alter system kill session '596,4793';
```
