[TOC]

# OpenLDAP基础配置

1. 环境准备

```
test0# setenforce 0
test0# getenforce
        Disabled
test0# firewall-cmd --permanent --add-port=389/tcp
test0# firewall-cmd --reload
test0# yum install -y openldap openldap-clients openldap-servers
test0# chronyc -c makestep
test0# systemctl restart chronyd
test0# systemctl enable slapd
test0# systemctl start slapd
```

2.  初始化OpenLDAP并设置LDAP管理员密码

```
test0# slappasswd -h {SHA} -s ycigIlink@123
    {SHA}Dfc9/HwBkeqK47Pe7iUSbfnH19M=
test0# vim admin.ldif
    dn: olcDatabase={2}hdb,cn=config
    changetype: modify
    replace: olcSuffix
    olcSuffix: dc=ycigilink,dc=com

    dn: olcDatabase={2}hdb,cn=config
    changetype: modify
    replace: olcRootDN
    olcRootDN: cn=admin,dc=ycigilink,dc=com

    dn: olcDatabase={2}hdb,cn=config
    changetype: modify
    replace: olcRootPW
    olcRootPW: {SHA}Dfc9/HwBkeqK47Pe7iUSbfnH19M=

    dn: olcDatabase={1}monitor,cn=config
    changetype: modify
    replace: olcAccess
    olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" read by dn.base="cn=admin,dc=ycigilink,dc=com" read by * none
test0# ldapmodify -Y EXTERNAL -H ldapi:/// -f admin.ldif
```

**注意：“monitor.ldif”文件中的“read by dn.base”为dn.base的管理员，需要按实际情况手动配置。**

3.  配置LDAP数据库并导入数据

```
test0# cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
test0# chown -R ldap.ldap /var/lib/ldap/
test0# ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
test0# ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
test0# ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif
```

4. 配置OpenLDAP基础数据库

```
test0# vim base.ldif
    dn: dc=ycigilink,dc=com
    o: company
    objectClass: top
    objectclass: dcObject
    objectclass: organization

    dn: cn=admin,dc=ycigilink,dc=com
    cn: admin
    objectClass: organizationalRole
    description: Directory Manage
test0# ldapadd -x -w ycigIlink@123 -D "cn=admin,dc=ycigilink,dc=com" -f base.ldif
```

5. 开启OpenLDAP日志与rsyslog系统日志

```
test0# vim loglevel.ldif
    dn: cn=config
    changetype: modify
    replace: olcLogLevel
    olcLogLevel: stats
test0# ldapmodify -Y EXTERNAL -H ldapi:/// -f loglevel.ldif
test0# vim /etc/rsyslog.conf +73
    local4.*                         /var/log/slapd.log
test0# systemctl restart rsyslog
test0# systemctl restart slapd
```

6. 禁止匿名访问
```
test0# vim disable_anon.ldif
    dn: cn=config
    changetype: modify
    add: olcDisallows
    olcDisallows: bind_anon

    dn: cn=config
    changetype: modify
    add: olcRequires
    olcRequires: authc

    dn: olcDatabase={-1}frontend,cn=config
    changetype: modify
    add: olcRequires
    olcRequires: authc
test0# ldapadd -Q -Y EXTERNAL -H ldapi:/// -f disable_anon.ldif
```

7. 设置ACL
* 添加ACL控制
```
test0# vim acl.ldif
    dn: olcDatabase={2}hdb,cn=config
    changetype: modify
    replace: olcAccess
    olcAccess: to attrs=userPassword
      by anonymous auth
      by dn.base="cn=admin,dc=ycigilink,dc=com" write
      by self write
      by * none
    olcAccess: to *
      by anonymous auth
      by dn.base="cn=admin,dc=ycigilink,dc=com" write
      by dn.base="cn=luqq,cn=groups,dc=ycigilink,dc=com" read
      by * none
test0#  ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f acl.ldif
```

**对于主从的两个节点需要分别配置ACL。**

* 删除ACL控制
```
test0# vim del_acl.ldif
    dn: olcDatabase={2}hdb,cn=config
    changetype: modify
    delete: olcAccess
    olcAccess: {0}
test0# ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f acl.ldif
```

# 导入memberOf模块

1. 创建memberOf导入文件

```
test0# vim memberof_conf.ldif
    dn: cn=module,cn=config
    cn: module
    objectClass: olcModuleList
    olcModuleLoad: memberof
    olcModulePath: /usr/lib64/openldap

    dn: olcOverlay={0}memberof,olcDatabase={2}hdb,cn=config
    objectClass: olcConfig
    objectClass: olcMemberOf
    objectClass: olcOverlayConfig
    objectClass: top
    olcOverlay: memberof
    olcMemberOfDangling: ignore
    olcMemberOfRefInt: TRUE
    olcMemberOfGroupOC: groupOfNames
    olcMemberOfMemberAD: member
    olcMemberOfMemberOfAD: memberOf
test0# vim refint1.ldif
    dn: cn=module{0},cn=config
    add: olcmoduleload
    olcmoduleload: refint
test0# vim refint2.ldif
    dn: olcOverlay={1}refint,olcDatabase={2}hdb,cn=config
    objectClass: olcConfig
    objectClass: olcOverlayConfig
    objectClass: olcRefintConfig
    objectClass: top
    olcOverlay: {1}refint
    olcRefintAttribute: memberof member manager owner
```

2. 导入各模块文件

```
test0# ldapadd -Q -Y EXTERNAL -H ldapi:/// -f memberof_conf.ldif
test0# ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f refint1.ldif
test0# ldapadd -Q -Y EXTERNAL -H ldapi:/// -f refint2.ldif
test0# slapcat -b cn=config
```

# 导入sync模块

```
test0# vim syncprov_mod.ldif
    dn: cn=module,cn=config
    objectClass: olcModuleList
    cn: module
    olcModulePath: /usr/lib64/openldap
    olcModuleLoad: syncprov.la
test0# ldapadd -Y EXTERNAL -H ldapi:/// -f syncprov_mod.ldif
test0# vim syncprov.ldif
    dn: olcOverlay=syncprov,olcDatabase={2}hdb,cn=config
    objectClass: olcOverlayConfig
    objectClass: olcSyncProvConfig
    olcOverlay: syncprov
    olcSpSessionLog: 100
test0# ldapadd -Y EXTERNAL -H ldapi:/// -f syncprov.ldif
test0# vim rpuser.ldif
    dn: uid=repl,dc=ycigilink,dc=com
    objectClass: simpleSecurityObject
    objectclass: account
    uid: repl
    description: Replication User
    userPassword: ycigRepl@123
test0# ldapadd -x -w ycigIlink@123 -D "cn=admin,dc=ycigilink,dc=com" -f rpuser.ldif
test0# slapcat -b cn=config
```

# OpenLDAP主从同步

```
test0# vim ldapsync.ldif
    dn: olcDatabase={2}hdb,cn=config
    changetype: modify
    add: olcSyncRepl
    olcSyncRepl: rid=001
      provider=ldap://192.168.3.191:389/
      bindmethod=simple
      binddn="uid=repl,dc=ycigilink,dc=com"
      credentials=ycigRepl@123
      searchbase="dc=ycigilink,dc=com"
      scope=sub
      schemachecking=on
      type=refreshAndPersist
      retry="30 5 300 3"
      interval=00:00:00:10
test0# ldapadd -Y EXTERNAL -H ldapi:/// -f ldapsync.ldif
```

**如需实现OpenLDAP主从建议先配置好ACL。**

# 安装phpldapadmin

1. 环境准备

```
test0# yum -y install phpldapadmin
test0# firewall-cmd --permanent --add-port=80/tcp
test0# firewall-cmd --reload
```

2. 修改配置文件

```
test0# vim /etc/phpldapadmin/config.php +397
    $servers->setValue('login','attr','dn');
    // $servers->setValue('login','attr','uid');
test0# vim /etc/httpd/conf.d/phpldapadmin.conf
    Alias /phpldapadmin /usr/share/phpldapadmin/htdocs
    Alias /ldapadmin /usr/share/phpldapadmin/htdocs

    <Directory /usr/share/phpldapadmin/htdocs>
      <IfModule mod_authz_core.c>
        # Apache 2.4
        Require local
        Require ip 192.168.3.0/24
        Require all granted
      </IfModule>
      <IfModule !mod_authz_core.c>
        # Apache 2.2
        Order Deny,Allow
        Deny from all
        Allow from 127.0.0.1
        Allow from ::1
      </IfModule>
    </Directory>
test0# systemctl restart httpd
test0# systemctl enable httpd
test0# curl -I 192.168.3.191/ldapadmin/
```

# 安装self-service-password服务

1. 下载并安装self-service-password
```
test0# vim /etc/yum.repos.d/ltb-project.repo
    [ltb-project-noarch]
    name=LTB project packages (noarch)
    baseurl=https://ltb-project.org/rpm/7/x86_64/
    enabled=1
    gpgcheck=0
test0# wget https://ltb-project.org/archives/self-service-password-1.3-1.el7.noarch.rpm
test0# yum -y localinstall self-service-password-1.3-1.el7.noarch.rpm
```

2. 修改apache配置文件
```
test0# # vim /etc/httpd/conf.d/self-service-password.conf
    <VirtualHost *>
            ServerName ssp.example.com

            DocumentRoot /usr/share/self-service-password
            DirectoryIndex index.php

            AddDefaultCharset UTF-8

            <Directory /usr/share/self-service-password>
                AllowOverride None
                <IfVersion >= 2.3>
                    Require all granted
                </IfVersion>
                <IfVersion < 2.3>
                    Order Deny,Allow
                    Allow from all
                </IfVersion>
            </Directory>

            <Directory /usr/share/self-service-password/scripts>
                AllowOverride None
                <IfVersion >= 2.3>
                    Require all denied
                </IfVersion>
                <IfVersion < 2.3>
                    Order Deny,Allow
                    Deny from all
                </IfVersion>
            </Directory>

            LogLevel warn
            ErrorLog /var/log/httpd/ssp_error_log
            CustomLog /var/log/httpd/ssp_access_log combined
    </VirtualHost>
test0# systemctl restart httpd
```

3. 修改Self Service Password的配置文件
```
test0# vim /usr/share/self-service-password/conf/config.inc.php
    $ldap_url = "ldap://192.168.3.197:389";
    $ldap_starttls = false;
    $ldap_binddn = "cn=admin,dc=ycigilink,dc=com";
    $ldap_bindpw = "ycig1234";
    $ldap_base = "dc=ycigilink,dc=com";
    $ldap_login_attribute = "cn";
    #$ldap_login_attribute = "uid";
    $ldap_fullname_attribute = "cn";
    $ldap_filter = "(&(objectClass=person)($ldap_login_attribute={login}))";
    $use_questions=false;
    $use_sms= false;
    $keyphrase = "65093cc02ddc493e20e4dde5feb78100eb513c06";
    $who_change_password = "manager";
test0# systemctl restart httpd
```

**注意：如禁止了匿名访问则必需开启ACL，否则无法修改用户密码。**

# 添加具有memberOf属性的组

```
test0# vim gitlab_member.ldif
    dn: ou=YCIG_Services,dc=ycigilink,dc=com
    description:: 5YWs5Y+45YaF572R5pyN5Yqh57uE
    objectclass: organizationalUnit
    objectclass: top
    ou: YCIG_Services

    dn: cn=GitLab,ou=YCIG_Services,dc=ycigilink,dc=com
    cn: GitLab
    member: cn=luqq,cn=Operators,ou=RDC,dc=ycigilink,dc=com
    member: cn=lujp,cn=Operators,ou=RDC,dc=ycigilink,dc=com
    objectclass: groupOfNames
    objectclass: top
test0# ldapadd -x -D cn=admin,dc=ycigilink,dc=com -w ycigIlink@123 -f add_memberOf.ldif
test0# ldapsearch -x -LLL -H ldapi:/// -D cn=admin,dc=ycigilink,dc=com -w ycigIlink@123 -b cn=luqq,cn=Operators,ou=RDC,dc=ycigilink,dc=com memberOf
```

# GitLab关联OpenLDAP认证

```
test0# vim /etc/gitlab/gitlab.rb
     gitlab_rails['ldap_enabled'] = true
     gitlab_rails['ldap_servers'] = YAML.load <<-'EOS'
       main: # 'main' is the GitLab 'provider ID' of this LDAP server
         label: 'ycigilink openldap'
         host: '192.168.3.251'
         port: 389
         uid: 'sAMAccountName'
         uid: 'uid'
         bind_dn: 'cn=admin,dc=ycigilink,dc=com'
         password: 'ycigIlink@123'
         encryption: 'plain'
         smartcard_auth: false
         active_directory: true
         allow_username_or_email_login: false
         base: 'ou=RDC,dc=ycigilink,dc=com'
         user_filter: 'memberOf=cn=GitLab,ou=YCIG_Services,dc=ycigilink,dc=com'
         ## EE only
         group_base: ''
         admin_group: ''
         sync_ssh_keys: false
     EOS
test0# gitlab-ctl reconfigure
```

# teleport关联至OpenLDAP认证

在用户管理的窗口按如下规则填写：
    LDAP主机：192.168.3.251
    端口：389
    域：dc=ycigilink,dc=com
    管理员DN：cn=admin,dc=ycigilink,dc=com
    密码：
    用户基准DN：ou=RDC,dc=ycigilink,dc=com
    过滤器：(&(memberOf=cn=teleport,ou=YCIG_Services,dc=ycigilink,dc=com))
    属性映射：
        登陆账号字段：cn
        真实姓名字段：displayName
        邮箱地址字段：mail

# OpenVPN关联至OpenLDAP认证

ldapsearch -LLL -w ycigIlink@123 -x -H ldap://192.168.3.251 -D "cn=admin,dc=ycigilink,dc=com" -b "cn=OpenVPN,ou=YCIG_Services,dc=ycigilink,dc=com" member  | awk '/^member/{print $2}' | grep "^cn=luqq"

# 在grafana中使用openldap进行授权认证

在openldap中导入如下的memberOf用户组

```
# 条目 1: ou=grafana,ou=YCIG_Services,dc=ycigilink,dc=com
dn: ou=grafana,ou=YCIG_Services,dc=ycigilink,dc=com
objectclass: organizationalUnit
objectclass: top
ou: grafana

# 条目 2: cn=grafana-admin,ou=grafana,ou=YCIG_Services,dc=ycigilink,dc=...
dn: cn=grafana-admin,ou=grafana,ou=YCIG_Services,dc=ycigilink,dc=com
cn: grafana-admin
member: cn=lujp,cn=Operators,ou=RDC,dc=ycigilink,dc=com
member: cn=luqq,cn=Operators,ou=RDC,dc=ycigilink,dc=com
objectclass: groupOfNames
objectclass: top

# 条目 3: cn=grafana-users,ou=grafana,ou=YCIG_Services,dc=ycigilink,dc=...
dn: cn=grafana-users,ou=grafana,ou=YCIG_Services,dc=ycigilink,dc=com
cn: grafana-users
member: cn=t1,cn=Operators,ou=RDC,dc=ycigilink,dc=com
objectclass: groupOfNames
objectclass: top
```

通过以上配置可知grafana分为两个权限组：grafana-admin和grafana-users，两个组内均已配置用户。

在grafana中defaults.ini的配置如下：

```
[auth.ldap]
enabled = true
config_file = /usr/local/grafana/conf/ldap.toml
allow_sign_up = true
sync_cron = "0 0 1 * * *"
active_sync_enabled = true

[log]
level = debug
filters = ldap:debug

```

在grafana的主配置文件中确定使用ldap进行用户认证，在调试ldap认证的过程中建议将日志的级别调整为debug，以便查看授权过程。

修改ldap.toml的配置文件，将grafana的认证通过检索ldap的用户组来实现。

```
[[servers]]
host = "ldap.ycigilink.local"
port = 389
use_ssl = false
start_tls = false
# 连接ldap的过程不使用ssl的认证
ssl_skip_verify = true
# 指定连接ldap的管理员用户，此处可不必使用ldap的管理员，只需要使用具有查询权限的用户即可
bind_dn = "cn=admin,dc=ycigilink,dc=com"
bind_password = 'ycigIlink@123'
# 指定用户输入的用户名对应为ldap的中的哪个资源，此处配置为登陆时用户在用户名处输入的为cn，后面将会基于该cn进行检索
search_filter = "(cn=%s)"
# 指定用户基于哪个dn进行检索
search_base_dns = ["ou=RDC,dc=ycigilink,dc=com"]

# 以下配置为属性映射关系
[servers.attributes]
# 将ldap中的“displayName”映射为用户属性中的“name”
name = "displayName"
surname = "sn"
username = "cn"
member_of = "memberOf"
email =  "Email"

# 配置不同权限组的映射关系
[[servers.group_mappings]]
# 指定grafana-admin为管理员权限
group_dn = "cn=grafana-admin,ou=grafana,ou=YCIG_Services,dc=ycigilink,dc=com"
org_role = "Admin"

[[servers.group_mappings]]

[[servers.group_mappings]]
# 指定grafana-users为只读权限
group_dn = "cn=grafana-users,ou=grafana,ou=YCIG_Services,dc=ycigilink,dc=com"
org_role = "Viewer"
```