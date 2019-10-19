#!/bin/bash
yum install http://repo.zabbix.com/zabbix/4.2/rhel/7/x86_64/zabbix-release-4.2-1.el7.noarch.rpm -y
yum install zabbix-agent -y

# create config for zabbix_agentd.conf
rm -f /etc/zabbix/zabbix_agentd.conf
cat << EOF > /etc/zabbix/zabbix_agentd.conf
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0
Server=192.168.56.77
ServerActive=192.168.56.77
Hostname=centos2
Include=/etc/zabbix/zabbix_agentd.d/*.conf
HostMetadata=system.uname
EOF

systemctl start zabbix-agent
systemctl enable zabbix-agent
