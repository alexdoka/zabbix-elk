#!/bin/bash
yum install mc vim bash-completion -y
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

cat << EOF > /etc/yum.repos.d/elasticsearch.repo
[elasticsearch-7.x]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

yum install elasticsearch -y
echo -e "transport.host: localhost \nhttp.port: 9200\nnetwork.host: 0.0.0.0" >> /etc/elasticsearch/elasticsearch.yml
systemctl daemon-reload
systemctl enable elasticsearch.service
systemctl start elasticsearch.service


yum install kibana -y
systemctl daemon-reload

cat << EOF > /etc/kibana/kibana.yml
server.host: "0.0.0.0"
EOF

systemctl enable kibana.service
systemctl start kibana.service




