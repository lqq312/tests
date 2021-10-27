#!/bin/bash

# 调整内核参数

TotalMem=`free -b | awk '/^Mem/{print $2}'`
let "KernelShmall=${TotalMem}/4"
OracleHomeDir="/u01/app/oracle/product/12.2.0/dbhome_1"
Hostname=`hostname`
LocalIP=`hostname -i`
OraclePackage="$1"
SwapSize=`free -b | awk '/^Swap/{print $2}'`
DBInstallRes="/u01/database/response/db_install.rsp"
DBCARes="/u01/database/response/dbca.rsp"
OracleSid="IOT"

cat > /etc/sysctl.d/97-oracledatabase-sysctl.conf << EOF
fs.aio-max-nr=1048576
fs.file-max=6815744
# kernel.shmmax设置为物理内存的90%即可（最好能比MEMORY_TARGET大），可取的最大值为物理内存值 -1byte（12G物理内存，该值应该设置为12*1024*1024*1024 -1）
kernel.shmmax=${TotalMem}
# 可以使用的共享内存的总页数，将kernel.shmmax的值除以4
kernel.shmall=${KernelShmall}
kernel.shmmni=4096
kernel.sem=250 32000 100 128
net.ipv4.ip_local_port_range=9000 65500
net.core.rmem_default=262144
net.core.rmem_max=4194304
net.core.wmem_default=262144
net.core.wmem_max=1048576
EOF

cat > /etc/security/limits.d/97-oracle.conf << EOF
oracle soft nproc 2047
oracle hard nproc 16384
oracle soft nofile 1024
oracle hard nofile 65536
oracle soft stack 3145728
oracle hard stack 3145728
EOF

# 增加oracle系统用户

groupadd -r oinstall
groupadd -r dba

if id oracle &> /dev/null; then
	userdel -r oracle
else
	useradd -g oinstall -G dba oracle
fi

echo "oracle" | passwd oracle --stdin &> /dev/null

mkdir -p ${OracleHomeDir}

chown -R oracle.oinstall /u01
chmod -R 775 /u01

# 增加oracle用户的系统环境变量
cat >> /home/oracle/.bash_profile << EOF
export ORACLE_SID=${OracleSid}
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=\${ORACLE_BASE}/product/12.2.0/dbhome_1
export PATH=\${ORACLE_HOME}/bin:${PATH}
EOF

# 设置SELinux为disable

sed -i 's#SELINUX=.*$#SELINUX=disabled#' /etc/selinux/config
setenforce 0

systemctl stop firewalld
systemctl disable firewalld

cat > /etc/hosts << EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

${LocalIP} oracle
EOF

sed -i 's#\(GRUB_CMDLINE_LINUX=\).*#\1crashkernel=auto rhgb quiet transparent_hugepage=never#' /etc/default/grub

yum -y -q install binutils compat-libcap1-1.10 libgcc libstdc++ libstdc++-devel sysstat gcc-c++ ksh make glibc glibc-devel libaio libaio-devel smartmontools net-tools zip unzip

# 设置swap的大小
if [[ ${TotalMem} -le 2147483648 ]]; then
	let "SwapFileSize=((${TotalMem}*1.5-${SwapSize})/1024/1024/1024)+1"
	mkdir -p /opt/swap_files
	dd if=/dev/zero of=/opt/swap_files/swap_file01 bs=1G count=${SwapFileSize}
	chmod 600 /opt/swap_files/swap_file01
	mkswap /opt/swap_files/swap_file01
	echo "/opt/swap_files/swap_file01 swap swap defaults 0 0" >> /etc/fstab
elif [[ ${TotalMem} -gt 2147483648 ]] && [[ ${TotalMem} -lt 17179869184 ]]; then
	let "SwapFileSize=((${TotalMem}-${SwapSize})/1024/1024/1024)+1"
	mkdir -p /opt/swap_files
	dd if=/dev/zero of=/opt/swap_files/swap_file01 bs=1G count=${SwapFileSize}
	chmod 600 /opt/swap_files/swap_file01
	mkswap /opt/swap_files/swap_file01
	echo "/opt/swap_files/swap_file01 swap swap defaults 0 0" >> /etc/fstab
else
	let "SwapFileSize=((17179869184-${SwapSize})/1024/1024/1024)+1"
	mkdir -p /opt/swap_files
	dd if=/dev/zero of=/opt/swap_files/swap_file01 bs=1G count=${SwapFileSize}
	chmod 600 /opt/swap_files/swap_file01
	mkswap /opt/swap_files/swap_file01
	echo "/opt/swap_files/swap_file01 swap swap defaults 0 0" >> /etc/fstab
fi

swapon -a

unzip -q ${OraclePackage} -d /u01

cp ${DBInstallRes}{,.bak}
sed -i '30s#\(oracle.install.option=\).*$#\1INSTALL_DB_AND_CONFIG#' ${DBInstallRes}
sed -i '35s#\(UNIX_GROUP_NAME=\).*$#\1oinstall#' ${DBInstallRes}
sed -i '42s#\(INVENTORY_LOCATION=\).*$#\1/u01/app/oraInventory#' ${DBInstallRes}
sed -i '46s#\(ORACLE_HOME=\).*$#\1'''${OracleHomeDir}'''#' ${DBInstallRes}
sed -i '51s#\(ORACLE_BASE=\).*$#\1/u01/app/oracle#' ${DBInstallRes}
sed -i '63s#\(oracle.install.db.InstallEdition=\).*$#\1EE#' ${DBInstallRes}
sed -i '80s#\(oracle.install.db.OSDBA_GROUP=\).*$#\1dba#' ${DBInstallRes}
sed -i '86s#\(oracle.install.db.OSOPER_GROUP=\).*$#\1dba#' ${DBInstallRes}
sed -i '91s#\(oracle.install.db.OSBACKUPDBA_GROUP=\).*$#\1dba#' ${DBInstallRes}
sed -i '96s#\(oracle.install.db.OSDGDBA_GROUP=\).*$#\1dba#' ${DBInstallRes}
sed -i '101s#\(oracle.install.db.OSKMDBA_GROUP=\).*$#\1dba#' ${DBInstallRes}
sed -i '106s#\(oracle.install.db.OSRACDBA_GROUP=\).*$#\1dba#' ${DBInstallRes}
sed -i '180s#\(oracle.install.db.config.starterdb.type=\).*$#\1GENERAL_PURPOSE#' ${DBInstallRes}
sed -i '185s#\(oracle.install.db.config.starterdb.globalDBName=\).*$#\1'''${OracleSid}'''#' ${DBInstallRes}
sed -i '190s#\(oracle.install.db.config.starterdb.SID=\).*$#\1'''${OracleSid}'''#' ${DBInstallRes}
sed -i '197s#\(oracle.install.db.ConfigureAsContainerDB=\).*$#\1false#' ${DBInstallRes}
sed -i '216s#\(oracle.install.db.config.starterdb.characterSet=\).*$#\1ZHS16GBK#' ${DBInstallRes}
sed -i '232s#\(oracle.install.db.config.starterdb.memoryLimit=\).*$#\1512#' ${DBInstallRes}
sed -i '259s#\(oracle.install.db.config.starterdb.password.ALL=\).*$#\1oracle#' ${DBInstallRes}
sed -i '334s#\(oracle.install.db.config.starterdb.storageType=\).*$#\1FILE_SYSTEM_STORAGE#' ${DBInstallRes}
sed -i '342s#\(oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=\).*$#\1/u01/app/oracle/oradata#' ${DBInstallRes}
sed -i '398s#\( DECLINE_SECURITY_UPDATES=\).*$#\1true#' ${DBInstallRes}

cp ${DBCARes}{,.bak}
sed -i '32s#\(gdbName=\).*$#\1'''${OracleSid}'''#' ${DBCARes}
sed -i '42s#\(sid=\).*$#\1'''${OracleSid}'''#' ${DBCARes}
sed -i '52s#\(databaseConfigType=\).*$#\1SI#' ${DBCARes}
sed -i '74s#\(policyManaged=\).*$#\1false#' ${DBCARes}
sed -i '88s#\(createServerPool=\).*$#\1false#' ${DBCARes}
sed -i '127s#\(force=\).*$#\1false#' ${DBCARes}
sed -i '162s#\(createAsContainerDatabase=\).*$#\1false#' ${DBCARes}
sed -i '223s#\(templateName=\).*$#\1/u01/app/oracle/product/12.2.0/dbhome_1/assistants/dbca/templates/General_Purpose.dbc#' ${DBCARes}
sed -i '233s#\(sysPassword=\).*$#\1Oracle@123#' ${DBCARes}
sed -i '243s#\(systemPassword=\).*$#\1Oracle@123#' ${DBCARes}
sed -i '252s#\(oracleHomeUserPassword=\).*$#\1Oracle@123#' ${DBCARes}
sed -i '284s#\(runCVUChecks=\).*$#\1false#' ${DBCARes}
sed -i '313s#\(omsPort=\).*$#\10#' ${DBCARes}
sed -i '341s#\(dvConfiguration=\).*$#\1false#' ${DBCARes}
sed -i '391s#\(olsConfiguration=\).*$#\1false#' ${DBCARes}
sed -i '401s#\(datafileJarLocation=\).*$#\1{ORACLE_HOME}/assistants/dbca/templates/#' ${DBCARes}
sed -i '411s#\(datafileDestination=\).*$#\1{ORACLE_BASE}/oradata/{DB_UNIQUE_NAME}/#' ${DBCARes}
sed -i '421s#\(recoveryAreaDestination=\).*$#\1{ORACLE_BASE}/fast_recovery_area/{DB_UNIQUE_NAME}#' ${DBCARes}
sed -i '431s#\(storageType=\).*$#\1FS#' ${DBCARes}
sed -i '468s#\(characterSet=\).*$#\1ZHS16GBK#' ${DBCARes}
sed -i '478s#\(nationalCharacterSet=\).*$#\1UTF8#' ${DBCARes}
sed -i '488s#\(registerWithDirService=\).*$#\1false#' ${DBCARes}
sed -i '526s#\(listeners=\).*$#\1LISTENER#' ${DBCARes}
sed -i '546s#\(variables=\).*$#\1DB_UNIQUE_NAME='''${OracleSid}''',ORACLE_BASE=/u01/app/oracle,PDB_NAME=,DB_NAME='''${OracleSid}''',ORACLE_HOME=/u01/app/oracle/product/12.2.0/dbhome_1,SID='''${OracleSid}'''#' ${DBCARes}
sed -i '555s#\(initParams=\).*$#\1undo_tablespace=UNDOTBS1,memory_target=796MB,processes=300,db_recovery_file_dest_size=2780MB,nls_language=AMERICAN,dispatchers=(PROTOCOL=TCP) (SERVICE='''${OracleSid}'''),db_recovery_file_dest={ORACLE_BASE}/fast_recovery_area/{DB_UNIQUE_NAME},db_block_size=8192BYTES,diagnostic_dest={ORACLE_BASE},audit_file_dest={ORACLE_BASE}/admin/{DB_UNIQUE_NAME}/adump,nls_territory=AMERICA,local_listener=LISTENER_CDB1,compatible=12.2.0,control_files=("{ORACLE_BASE}/oradata/{DB_UNIQUE_NAME}/control01.ctl", "{ORACLE_BASE}/fast_recovery_area/{DB_UNIQUE_NAME}/control02.ctl"),db_name='''${OracleSid}''',audit_trail=db,remote_login_passwordfile=EXCLUSIVE,open_cursors=300#' ${DBCARes}
sed -i '565s#\(sampleSchema=\).*$#\1false#' ${DBCARes}
sed -i '574s#\(memoryPercentage=\).*$#\140#' ${DBCARes}
sed -i '584s#\(databaseType=\).*$#\1MULTIPURPOSE#' ${DBCARes}
sed -i '594s#\(automaticMemoryManagement=\).*$#\1false#' ${DBCARes}
sed -i '604s#\(totalMemory=\).*$#\10#' ${DBCARes}

su oracle -lc "/u01/database/runInstaller -force -silent -noconfig -responseFile ${DBInstallRes}"
exit
/u01/app/oraInventory/orainstRoot.sh
/u01/app/oracle/product/12.2.0/dbhome_1/root.sh

su oracle -lc "${OracleHomeDir}/bin/netca -silent -responsefile /u01/database/response/netca.rsp"
exit

su oracle -lc "${OracleHomeDir}/bin/dbca -silent -createDatabase -responseFile ${DBCARes}"