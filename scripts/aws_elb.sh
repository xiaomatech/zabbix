#!/bin/bash

python /etc/zabbix/scripts/aws_elb.py -k $1 -s $2 -r $3 -n $4 > /tmp/$4.data
/usr/bin/zabbix_sender -vv -z 127.0.0.1 -i /tmp/$4.data 2>&1 | tee /var/tmp/elb.out
