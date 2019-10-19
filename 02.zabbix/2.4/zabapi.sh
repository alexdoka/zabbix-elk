#!/bin/bash

#Variables
zabapi="http://192.168.56.77/zabbix/api_jsonrpc.php"
ipagent="192.168.56.78"
zuser="Admin"
zpassword="zabbix"

#==================================================================

hn=$(hostname)

function get_id_cloudhost {
	id_cloudhost=$(jq '.result[0].groupid' <<< $(curl --silent -H "Content-Type: application/json-rpc" -X POST $zabapi -d'
	{
	    "jsonrpc": "2.0",
	    "method": "hostgroup.get",
	    "params": {
		"output": "extend",
		"filter": {
		    "name": 
			"CloudHost"
		}
	    },
	    "auth": '$sessionid',
	    "id": 1
	}'))
}


function create_host_group {
	#create host group
	curl --silent -H "Content-Type: application/json-rpc" -X POST $zabapi -d'
	{
	    "jsonrpc": "2.0",
	    "method": "hostgroup.create",
	    "params": {
		"name": "CloudHost"
	    },
	    "auth": '$sessionid',
	    "id": 1
	}'
}


function get_host_id {
host_id=$(jq '.result[0].hostid' <<< $(curl --silent -H "Content-Type: application/json-rpc" -X POST $zabapi -d'
	{
	    "jsonrpc": "2.0",
	    "method": "host.get",
	    "params": {
		"filter": {
		    "host": [
			'\"$hn\"'
		    ]
		}
	    },
	    "auth": '$sessionid',
	    "id": 1
	}'))
}




sessionid=$(jq '.result' <<< $(curl --silent -H "Content-Type: application/json-rpc" -X POST $zabapi -d'
{
  "jsonrpc": "2.0",
  "method": "user.login",
  "params": {
    "user": '\"$zuser\"',
    "password": '\"$zpassword\"'
  },
  "id": 1
}'))
echo -e "\n"

get_id_cloudhost
echo -e "Cloudhost result is $id_cloudhost \n"

# if group cloudhost is not exist, create it and get its id
if [ "$id_cloudhost" == "null" ]
then
	create_host_group
	get_id_cloudhost
fi

echo -e "\n"

#creating host
curl --silent -H "Content-Type: application/json-rpc" -X POST $zabapi -d'
{
    "jsonrpc": "2.0",
    "method": "host.create",
    "params": {
        "host": '\"$hn\"',
        "interfaces": [
            {
                "type": 1,
                "main": 1,
                "useip": 1,
                "ip": '\"$ipagent\"',
                "dns": "",
                "port": "10050"
            }
        ],
        "groups": [
            {
                "groupid": '$id_cloudhost'
            }
        ]
    },
    "auth": '$sessionid',
    "id": 1
}'

echo -e "\n"


get_host_id
#applying test_template
curl --silent -H "Content-Type: application/json-rpc" -X POST $zabapi -d'
{
    "jsonrpc": "2.0",
    "method": "template.create",
    "params": {
        "host": "test_template",
        "groups": {
            "groupid": '$id_cloudhost'
        },
        "hosts": [
            {
                "hostid": '$host_id' 
            }
        ]
    },
    "auth": '$sessionid',
    "id": 1
}'


echo -e "\n"
