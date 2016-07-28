#!/bin/bash

UNIXTIME=" "`date '+%s'`" "
ZBX_SENDER="/usr/bin/zabbix_sender"
ZBX_SERVER=""
ZBX_SERVER_PORT="10051"
HOSTNAME=`hostname`" "
PDNS_REC_CTL="/usr/bin/rec_control"
TMP_FILE="/tmp/pdns_rec.txt"

# Running chech pdns-recursor
`${PDNS_REC_CTL} get`
if [ $? -eq 0 ]; then

	# ping Alive
	ping -c 1 ${ZBX_SERVER} > /dev/null 2>&1
	
	if [ $? -eq 0 ]; then
	
		# PowerDNS recursor stats
	
		# file delete
		if [ -f ${TMP_FILE} ]; then
			rm ${TMP_FILE}
		fi
	
		array=()
	
		# rec_control get-all
		array=(`${PDNS_REC_CTL} get-all | cut -f1`)
	
		for (( i = 0; i < ${#array[@]}; i++ ))
		do
			# rec_control valiable
			echo ${HOSTNAME} ${array[i]} ${UNIXTIME} `${PDNS_REC_CTL} get ${array[i]}` >> ${TMP_FILE}
		done
		
		# Zabbix send data
		${ZBX_SENDER} -z ${ZBX_SERVER} -p ${ZBX_SERVER_PORT} -T -i ${TMP_FILE} > /dev/null

	fi
fi