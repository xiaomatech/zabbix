#!/bin/sh

MongoAPI(){
 RespStr=$(/usr/bin/mongo --quiet --eval "print(JSON.stringify($1))" $2 | python -m json.tool 2>/dev/null)
 echo $RespStr
 [ $? != 0 ] && echo 0 && exit 1
}


MongoAPI 'db.getMongo().getDBs()'
DBStr=$((cat <<EOF
$RespStr
EOF
) | awk -F\\t '$1~/^databases..+.name$/ && $2!~/^local$/ {
 print $2
}')


if [ -z $1 ]; then
 MongoAPI 'db.serverStatus({cursors: 0, locks:0, wiredTiger: 0})'
 OutStr=$((cat <<EOF
$RespStr
EOF
 ) | awk -F\\t '$1~/^(metrics.(cursor.(open.total|timedOut)|document.(deleted|inserted|returned|updated))|connections.(current|available)|globalLock.(currentQueue.(readers|total|writers)|activeClients.(total|readers|writers)|totalTime)|extra_info.(heap_usage_bytes|page_faults)|mem.(resident|virtual|mapped)|uptime|network.(bytes(In|Out)|numRequests)|opcounters.(command|delete|getmore|insert|query|update))(.floatApprox)?$/ {
  sub(".floatApprox", "", $1)
  print "- mongodb." $1, int($2)
 }')

echo $OutStr

 IFS=$'\n'
 for db in $DBStr; do
  MongoAPI 'db.stats()' $db
  for par in $RespStr; do
    OutStr="$OutStr
- mongodb.${par%%	*}[$db] ${par#*	}"
  done
 done

 (cat <<EOF
$OutStr
EOF
 ) | /usr/bin/zabbix_sender --config /etc/zabbix/zabbix_agentd.conf --host=`hostname` --input-file - >/dev/null 2>&1
 echo 1
 exit 0

elif [ "$1" = 'db' ]; then
 es=''
 for db in $DBStr; do
  OutStr="$OutStr$es{\"{#DBNAME}\":\"${db#*	}\"}"
  es=","
 done
 echo -e "{\"data\":[$OutStr]}"
fi


