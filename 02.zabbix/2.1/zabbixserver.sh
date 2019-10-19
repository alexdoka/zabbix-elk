#!/bin/bash

#import vars from file
source /vagrant/envfile 

#install mariadb
yum install mariadb mariadb-server -y
/usr/bin/mysql_install_db --user=mysql --force
systemctl start mariadb
systemctl enable mariadb

# create db for zabbix
echo "create database $dbname character set utf8 collate utf8_bin;" | mysql -uroot
echo "grant all privileges on zabbix.* to zabbix@localhost identified by '$dbpassword';" | mysql -uroot

systemctl restart mariadb

#install zabbix
yum install http://repo.zabbix.com/zabbix/4.2/rhel/7/x86_64/zabbix-release-4.2-1.el7.noarch.rpm -y
yum install zabbix-server-mysql zabbix-web-mysql -y
yum install zabbix-server-mysql zabbix-web-mysql -y
yum install zabbix-server-mysql zabbix-web-mysql -y
yum install zabbix-server-mysql zabbix-web-mysql -y
yum install zabbix-server-mysql zabbix-web-mysql -y
yum install zabbix-server-mysql zabbix-web-mysql -y

#populate db 
echo "use zabbix; SET PASSWORD FOR 'zabbix'@'localhost' = PASSWORD('$dbpassword');" | mysql -uroot
zcat /usr/share/doc/zabbix-server-mysql-*/create.sql.gz | mysql -uzabbix -p$dbpassword zabbix

# edit config zabbix server
sed -i 's/# DBHost=localhost/DBHost=localhost/' /etc/zabbix/zabbix_server.conf
sed -i "s/# DBPassword=/DBPassword=$dbpassword/" /etc/zabbix/zabbix_server.conf

sed -i 's/# php_value date\.timezone Europe\/Riga/php_value date\.timezone Europe\/Minsk/' /etc/httpd/conf.d/zabbix.conf

# edit apache config for redirect
sed -i '/Alias \/zabbix \/usr\/share\/zabbix/a \
RewriteEngine  on \
RedirectMatch ^\/$ \/zabbix\/ \
' /etc/httpd/conf.d/zabbix.conf

systemctl restart httpd
systemctl enable httpd

yum install zabbix-agent -y
yum install zabbix-agent -y
yum install zabbix-agent -y

systemctl enable zabbix-agent
systemctl start zabbix-agent
systemctl enable zabbix-server
systemctl start zabbix-server

yum install zabbix-java-gateway -y
systemctl start zabbix-java-gateway -y
systemctl enable zabbix-java-gateway -y


rm -f /etc/zabbix/zabbix_server.conf
cat << EOF > /etc/zabbix/zabbix_server.conf
LogFile=/var/log/zabbix/zabbix_server.log
LogFileSize=0
PidFile=/var/run/zabbix/zabbix_server.pid
SocketDir=/var/run/zabbix
DBHost=localhost
DBName=$dbname
DBUser=zabbix
DBPassword=$dbpassword
JavaGateway=192.168.56.77
JavaGatewayPort=10052
StartJavaPollers=5
SNMPTrapperFile=/var/log/snmptrap/snmptrap.log
Timeout=4
AlertScriptsPath=/usr/lib/zabbix/alertscripts
ExternalScripts=/usr/lib/zabbix/externalscripts
LogSlowQueries=3000
StatsAllowedIP=127.0.0.1
EOF
systemctl restart zabbix-server




