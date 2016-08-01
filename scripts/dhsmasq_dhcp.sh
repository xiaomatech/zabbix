#!/bin/sh

INPUT_FILE=/var/log/dnsmasq.log
#DEBUG_LOG="/var/log/zabbix/$(basename $0).log"

ZABBIX_SENDER='/usr/bin/env zabbix_sender'
ZABBIX_CONFIG='/etc/zabbix/zabbix_agentd.conf'

awk -vct=${1:--} 'BEGIN{
		split("DISCOVER,REQUEST,DECLINE,RELEASE,INFORM,OFFER,ACK,NAK",list,",")
		for(i in list){array["DHCP"list[i]]=0}
	}
	/DHCPDISCOVER/{array["DHCPDISCOVER"]++}
	/DHCPREQUEST/{array["DHCPREQUEST"]++}
	/DHCPDECLINE/{array["DHCPDECLINE"]++}
	/DHCPRELEASE/{array["DHCPRELEASE"]++}
	/DHCPINFORM/{array["DHCPINFORM"]++}
	/DHCPOFFER/{array["DHCPOFFER"]++}
	/DHCPACK/{array["DHCPACK"]++}
	/DHCPNAK/{array["DHCPNAK"]++}
	#END{for(i in array){printf "- dnsmasq.dhcp[%s] %s\n",i,array[i]}}
	END{for(i in array){printf "%s dnsmasq.dhcp[%s] %s\n",ct,i,array[i]}}
	#END{for(i in array){print ct,"dnsmasq.dhcp["i"]",array[i]}}
' $INPUT_FILE | $ZABBIX_SENDER --config $ZABBIX_CONFIG \
	--input-file - -vv >>${DEBUG_LOG:-/dev/null} 2>&1

echo $?
exit 0
