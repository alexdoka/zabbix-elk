#!/bin/bash
yum install mc bash-completion wget -y

yum install tomcat -y
yum install tomcat-webapps tomcat-admin-webapps -y
systemctl start tomcat
systemctl enable tomcat

cp /vagrant/hello-world.war /var/lib/tomcat/webapps


wget https://artifacts.elastic.co/downloads/logstash/logstash-7.4.0.rpm
rpm -Uhv logstash-7.4.0.rpm 

cat << EOF > /etc/logstash/conf.d/tomcat.conf
input {
  file {
    path => "/var/log/tomcat/*"
    start_position => "beginning"
  }
}

output {
  elasticsearch {
    hosts => ["192.168.56.77:9200"]
  }
  stdout { codec => rubydebug }
}
EOF

chmod 777 /var/log/tomcat

systemctl start logstash.service
systemctl enable logstash.service

