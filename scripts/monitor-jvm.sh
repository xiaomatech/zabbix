#!/bin/bash

FPID="/tmp/pids"
TESTRUN=false
DEBUG=false
HOST=$(hostname)
TIMESTAMP=0
JAVA8=true

JPPID=""
JHPID=""
JSPID1=""
JSPID2=""
FIRST=true
JHSTAT=()
JPSTAT=()
JSTAT1=()
JSTAT2=()
SENDING_DATA=""
JHRUN=1
JPRUN=1
JS1RUN=1
JS2RUN=1
LOG="/tmp/jvm-monitor.log"
ZABBIX_AGENTD_CONF="/etc/zabbix/zabbix_agentd.conf"

function getPids {
  JPPID=$(<$FPID/process-controller.pid)
  JHPID=$(<$FPID/host-controller.pid)
  if [ -e "$FPID/slave-100.pid" ] ; then
    JSPID1=$(<$FPID/slave-100.pid)
  fi
  if [ -e "$FPID/slave-200.pid" ] ; then
    JSPID2=$(<$FPID/slave-200.pid)
  fi
}

function getJstat {
  if [ -n "$1" ]; then
    TIMESTAMP=$(date +%s)
    if [[ $platform == 'sunos' ]]; then
      /opt/local/bin/sudo /opt/local/java/openjdk7/bin/jstat -gc -t $1
    else
      sudo -H -u wildfly bash -c "/usr/local/bin/jstat -gc -t $1"
    fi
  fi
}

function emptyJstatArray7 {
  echo "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"
}

function emptyJstatArray8 {
  echo "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"
}

function checkStats {
  if [ "$JAVA8" = true ] ; then
    if [[ ${#JHSTAT[@]} < '18' ]] ; then JHSTAT=($(emptyJstatArray8)); JHRUN=0 ; fi
    if [[ ${#JPSTAT[@]} < '18' ]] ; then JPSTAT=($(emptyJstatArray8)); JPRUN=0 ; fi
    if [[ ${#JSTAT1[@]} < '18' ]] ; then JSTAT1=($(emptyJstatArray8)); JS1RUN=0 ; fi
    if [[ ${#JSTAT2[@]} < '18' ]] ; then JSTAT2=($(emptyJstatArray8)); JS2RUN=0 ; fi
  else
    if [[ ${#JHSTAT[@]} < '16' ]] ; then JHSTAT=($(emptyJstatArray7)); JHRUN=0 ; fi
    if [[ ${#JPSTAT[@]} < '16' ]] ; then JPSTAT=($(emptyJstatArray7)); JPRUN=0 ; fi
    if [[ ${#JSTAT1[@]} < '16' ]] ; then JSTAT1=($(emptyJstatArray7)); JS1RUN=0 ; fi
    if [[ ${#JSTAT2[@]} < '16' ]] ; then JSTAT2=($(emptyJstatArray7)); JS2RUN=0 ; fi
  fi
}

function getHostData7 {
  TIMESTAMP=$(date +%s)
  SENDING_DATA="\"$HOST\" jvm.hostcontroller.S0C $TIMESTAMP ${JHSTAT[1]}
\"$HOST\" jvm.hostcontroller.S1C $TIMESTAMP ${JHSTAT[2]}
\"$HOST\" jvm.hostcontroller.S0U $TIMESTAMP ${JHSTAT[3]}
\"$HOST\" jvm.hostcontroller.S1U $TIMESTAMP ${JHSTAT[4]}
\"$HOST\" jvm.hostcontroller.EC $TIMESTAMP ${JHSTAT[5]}
\"$HOST\" jvm.hostcontroller.EU $TIMESTAMP ${JHSTAT[6]}
\"$HOST\" jvm.hostcontroller.OC $TIMESTAMP ${JHSTAT[7]}
\"$HOST\" jvm.hostcontroller.OU $TIMESTAMP ${JHSTAT[8]}
\"$HOST\" jvm.hostcontroller.PC $TIMESTAMP ${JHSTAT[9]}
\"$HOST\" jvm.hostcontroller.PU $TIMESTAMP ${JHSTAT[10]}
\"$HOST\" jvm.hostcontroller.YGC $TIMESTAMP ${JHSTAT[11]}
\"$HOST\" jvm.hostcontroller.YGCT $TIMESTAMP ${JHSTAT[12]}
\"$HOST\" jvm.hostcontroller.FGC $TIMESTAMP ${JHSTAT[13]}
\"$HOST\" jvm.hostcontroller.FGCT $TIMESTAMP ${JHSTAT[14]}
\"$HOST\" jvm.hostcontroller.GCT $TIMESTAMP ${JHSTAT[15]}
\"$HOST\" jvm.hostcontroller.running $TIMESTAMP $JHRUN"
}

function getProcessData7 {
  TIMESTAMP=$(date +%s)
  SENDING_DATA="\"$HOST\" jvm.processcontroller.S0C $TIMESTAMP ${JPSTAT[1]}
\"$HOST\" jvm.processcontroller.S1C $TIMESTAMP ${JPSTAT[2]}
\"$HOST\" jvm.processcontroller.S0U $TIMESTAMP ${JPSTAT[3]}
\"$HOST\" jvm.processcontroller.S1U $TIMESTAMP ${JPSTAT[4]}
\"$HOST\" jvm.processcontroller.EC $TIMESTAMP ${JPSTAT[5]}
\"$HOST\" jvm.processcontroller.EU $TIMESTAMP ${JPSTAT[6]}
\"$HOST\" jvm.processcontroller.OC $TIMESTAMP ${JPSTAT[7]}
\"$HOST\" jvm.processcontroller.OU $TIMESTAMP ${JPSTAT[8]}
\"$HOST\" jvm.processcontroller.PC $TIMESTAMP ${JPSTAT[9]}
\"$HOST\" jvm.processcontroller.PU $TIMESTAMP ${JPSTAT[10]}
\"$HOST\" jvm.processcontroller.YGC $TIMESTAMP ${JPSTAT[11]}
\"$HOST\" jvm.processcontroller.YGCT $TIMESTAMP ${JPSTAT[12]}
\"$HOST\" jvm.processcontroller.FGC $TIMESTAMP ${JPSTAT[13]}
\"$HOST\" jvm.processcontroller.FGCT $TIMESTAMP ${JPSTAT[14]}
\"$HOST\" jvm.processcontroller.GCT $TIMESTAMP ${JPSTAT[15]}"
}

function getSlave100Data7 {
  TIMESTAMP=$(date +%s)
  SENDING_DATA="\"$HOST\" jvm.slave100.S0C $TIMESTAMP ${JSTAT1[1]}
\"$HOST\" jvm.slave100.S1C $TIMESTAMP ${JSTAT1[2]}
\"$HOST\" jvm.slave100.S0U $TIMESTAMP ${JSTAT1[3]}
\"$HOST\" jvm.slave100.S1U $TIMESTAMP ${JSTAT1[4]}
\"$HOST\" jvm.slave100.EC $TIMESTAMP ${JSTAT1[5]}
\"$HOST\" jvm.slave100.EU $TIMESTAMP ${JSTAT1[6]}
\"$HOST\" jvm.slave100.OC $TIMESTAMP ${JSTAT1[7]}
\"$HOST\" jvm.slave100.OU $TIMESTAMP ${JSTAT1[8]}
\"$HOST\" jvm.slave100.PC $TIMESTAMP ${JSTAT1[9]}
\"$HOST\" jvm.slave100.PU $TIMESTAMP ${JSTAT1[10]}
\"$HOST\" jvm.slave100.YGC $TIMESTAMP ${JSTAT1[11]}
\"$HOST\" jvm.slave100.YGCT $TIMESTAMP ${JSTAT1[12]}
\"$HOST\" jvm.slave100.FGC $TIMESTAMP ${JSTAT1[13]}
\"$HOST\" jvm.slave100.FGCT $TIMESTAMP ${JSTAT1[14]}
\"$HOST\" jvm.slave100.GCT $TIMESTAMP ${JSTAT1[15]}
\"$HOST\" jvm.slave100.running $TIMESTAMP $JS1RUN"
}

function getSlave200Data7 {
  TIMESTAMP=$(date +%s)
  SENDING_DATA="\"$HOST\" jvm.slave200.S0C $TIMESTAMP ${JSTAT2[1]}
\"$HOST\" jvm.slave200.S1C $TIMESTAMP ${JSTAT2[2]}
\"$HOST\" jvm.slave200.S0U $TIMESTAMP ${JSTAT2[3]}
\"$HOST\" jvm.slave200.S1U $TIMESTAMP ${JSTAT2[4]}
\"$HOST\" jvm.slave200.EC $TIMESTAMP ${JSTAT2[5]}
\"$HOST\" jvm.slave200.EU $TIMESTAMP ${JSTAT2[6]}
\"$HOST\" jvm.slave200.OC $TIMESTAMP ${JSTAT2[7]}
\"$HOST\" jvm.slave200.OU $TIMESTAMP ${JSTAT2[8]}
\"$HOST\" jvm.slave200.PC $TIMESTAMP ${JSTAT2[9]}
\"$HOST\" jvm.slave200.PU $TIMESTAMP ${JSTAT2[10]}
\"$HOST\" jvm.slave200.YGC $TIMESTAMP ${JSTAT2[11]}
\"$HOST\" jvm.slave200.YGCT $TIMESTAMP ${JSTAT2[12]}
\"$HOST\" jvm.slave200.FGC $TIMESTAMP ${JSTAT2[13]}
\"$HOST\" jvm.slave200.FGCT $TIMESTAMP ${JSTAT2[14]}
\"$HOST\" jvm.slave200.GCT $TIMESTAMP ${JSTAT2[15]}
\"$HOST\" jvm.slave200.running $TIMESTAMP $JS2RUN"
}

function getHostData8 {
  TIMESTAMP=$(date +%s)
  SENDING_DATA="\"$HOST\" jvm.hostcontroller.S0C $TIMESTAMP ${JHSTAT[1]}
\"$HOST\" jvm.hostcontroller.S1C $TIMESTAMP ${JHSTAT[2]}
\"$HOST\" jvm.hostcontroller.S0U $TIMESTAMP ${JHSTAT[3]}
\"$HOST\" jvm.hostcontroller.S1U $TIMESTAMP ${JHSTAT[4]}
\"$HOST\" jvm.hostcontroller.EC $TIMESTAMP ${JHSTAT[5]}
\"$HOST\" jvm.hostcontroller.EU $TIMESTAMP ${JHSTAT[6]}
\"$HOST\" jvm.hostcontroller.OC $TIMESTAMP ${JHSTAT[7]}
\"$HOST\" jvm.hostcontroller.OU $TIMESTAMP ${JHSTAT[8]}
\"$HOST\" jvm.hostcontroller.MC $TIMESTAMP ${JHSTAT[9]}
\"$HOST\" jvm.hostcontroller.MU $TIMESTAMP ${JHSTAT[10]}
\"$HOST\" jvm.hostcontroller.CCSC $TIMESTAMP ${JHSTAT[11]}
\"$HOST\" jvm.hostcontroller.CCSU $TIMESTAMP ${JHSTAT[12]}
\"$HOST\" jvm.hostcontroller.YGC $TIMESTAMP ${JHSTAT[13]}
\"$HOST\" jvm.hostcontroller.YGCT $TIMESTAMP ${JHSTAT[14]}
\"$HOST\" jvm.hostcontroller.FGC $TIMESTAMP ${JHSTAT[15]}
\"$HOST\" jvm.hostcontroller.FGCT $TIMESTAMP ${JHSTAT[16]}
\"$HOST\" jvm.hostcontroller.GCT $TIMESTAMP ${JHSTAT[17]}
\"$HOST\" jvm.hostcontroller.running $TIMESTAMP $JHRUN"
}

function getProcessData8 {
  TIMESTAMP=$(date +%s)
  SENDING_DATA="\"$HOST\" jvm.processcontroller.S0C $TIMESTAMP ${JPSTAT[1]}
\"$HOST\" jvm.processcontroller.S1C $TIMESTAMP ${JPSTAT[2]}
\"$HOST\" jvm.processcontroller.S0U $TIMESTAMP ${JPSTAT[3]}
\"$HOST\" jvm.processcontroller.S1U $TIMESTAMP ${JPSTAT[4]}
\"$HOST\" jvm.processcontroller.EC $TIMESTAMP ${JPSTAT[5]}
\"$HOST\" jvm.processcontroller.EU $TIMESTAMP ${JPSTAT[6]}
\"$HOST\" jvm.processcontroller.OC $TIMESTAMP ${JPSTAT[7]}
\"$HOST\" jvm.processcontroller.OU $TIMESTAMP ${JPSTAT[8]}
\"$HOST\" jvm.processcontroller.MC $TIMESTAMP ${JPSTAT[9]}
\"$HOST\" jvm.processcontroller.MU $TIMESTAMP ${JPSTAT[10]}
\"$HOST\" jvm.processcontroller.CCSC $TIMESTAMP ${JPSTAT[11]}
\"$HOST\" jvm.processcontroller.CCSU $TIMESTAMP ${JPSTAT[12]}
\"$HOST\" jvm.processcontroller.YGC $TIMESTAMP ${JPSTAT[13]}
\"$HOST\" jvm.processcontroller.YGCT $TIMESTAMP ${JPSTAT[14]}
\"$HOST\" jvm.processcontroller.FGC $TIMESTAMP ${JPSTAT[15]}
\"$HOST\" jvm.processcontroller.FGCT $TIMESTAMP ${JPSTAT[16]}
\"$HOST\" jvm.processcontroller.GCT $TIMESTAMP ${JPSTAT[17]}"
}

function getSlave100Data8 {
  TIMESTAMP=$(date +%s)
  SENDING_DATA="\"$HOST\" jvm.slave100.S0C $TIMESTAMP ${JSTAT1[1]}
\"$HOST\" jvm.slave100.S1C $TIMESTAMP ${JSTAT1[2]}
\"$HOST\" jvm.slave100.S0U $TIMESTAMP ${JSTAT1[3]}
\"$HOST\" jvm.slave100.S1U $TIMESTAMP ${JSTAT1[4]}
\"$HOST\" jvm.slave100.EC $TIMESTAMP ${JSTAT1[5]}
\"$HOST\" jvm.slave100.EU $TIMESTAMP ${JSTAT1[6]}
\"$HOST\" jvm.slave100.OC $TIMESTAMP ${JSTAT1[7]}
\"$HOST\" jvm.slave100.OU $TIMESTAMP ${JSTAT1[8]}
\"$HOST\" jvm.slave100.MC $TIMESTAMP ${JSTAT1[9]}
\"$HOST\" jvm.slave100.MU $TIMESTAMP ${JSTAT1[10]}
\"$HOST\" jvm.slave100.CCSC $TIMESTAMP ${JSTAT1[11]}
\"$HOST\" jvm.slave100.CCSU $TIMESTAMP ${JSTAT1[12]}
\"$HOST\" jvm.slave100.YGC $TIMESTAMP ${JSTAT1[13]}
\"$HOST\" jvm.slave100.YGCT $TIMESTAMP ${JSTAT1[14]}
\"$HOST\" jvm.slave100.FGC $TIMESTAMP ${JSTAT1[15]}
\"$HOST\" jvm.slave100.FGCT $TIMESTAMP ${JSTAT1[16]}
\"$HOST\" jvm.slave100.GCT $TIMESTAMP ${JSTAT1[17]}
\"$HOST\" jvm.slave100.running $TIMESTAMP $JS1RUN"
}

function getSlave200Data8 {
  TIMESTAMP=$(date +%s)
  SENDING_DATA="\"$HOST\" jvm.slave200.S0C $TIMESTAMP ${JSTAT2[1]}
\"$HOST\" jvm.slave200.S1C $TIMESTAMP ${JSTAT2[2]}
\"$HOST\" jvm.slave200.S0U $TIMESTAMP ${JSTAT2[3]}
\"$HOST\" jvm.slave200.S1U $TIMESTAMP ${JSTAT2[4]}
\"$HOST\" jvm.slave200.EC $TIMESTAMP ${JSTAT2[5]}
\"$HOST\" jvm.slave200.EU $TIMESTAMP ${JSTAT2[6]}
\"$HOST\" jvm.slave200.OC $TIMESTAMP ${JSTAT2[7]}
\"$HOST\" jvm.slave200.OU $TIMESTAMP ${JSTAT2[8]}
\"$HOST\" jvm.slave200.MC $TIMESTAMP ${JSTAT2[9]}
\"$HOST\" jvm.slave200.MU $TIMESTAMP ${JSTAT2[10]}
\"$HOST\" jvm.slave200.CCSC $TIMESTAMP ${JSTAT2[11]}
\"$HOST\" jvm.slave200.CCSU $TIMESTAMP ${JSTAT2[12]}
\"$HOST\" jvm.slave200.YGC $TIMESTAMP ${JSTAT2[13]}
\"$HOST\" jvm.slave200.YGCT $TIMESTAMP ${JSTAT2[14]}
\"$HOST\" jvm.slave200.FGC $TIMESTAMP ${JSTAT2[15]}
\"$HOST\" jvm.slave200.FGCT $TIMESTAMP ${JSTAT2[16]}
\"$HOST\" jvm.slave200.GCT $TIMESTAMP ${JSTAT2[17]}
\"$HOST\" jvm.slave200.running $TIMESTAMP $JS2RUN"
}

function sendStats {
  if [[ $platform == 'sunos' ]] ; then
    PREFIX='/opt/local/bin/'
  else
    PREFIX=""
  fi
  # zabbix_sender $ZS_PARAM -z service.theluckycatcasino.com -s "$(hostname)" -k "cluster.status" -o "$CLUSTER_STATUS" >> $TEMP_LOG_FILE
  if [ "$JAVA8" = true ] ; then
    getProcessData8
    sendData
    getHostData8
    sendData
    getSlave100Data8
    sendData
    getSlave200Data8
    sendData
  else
    getProcessData7
    sendData
    getHostData7
    sendData
    getSlave100Data7
    sendData
    getSlave200Data7
    sendData
  fi
}

function sendData {
  result=$(echo "$SENDING_DATA" | ${PREFIX}zabbix_sender -c $ZABBIX_AGENTD_CONF -v -T -i - 2>&1)
  if [ "$DEBUG" = true ]
  then
    echo "$SENDING_DATA" >> $LOG
    echo "Result: $result" >> $LOG
  fi
}

function echoStats {
  if [[ $platform == 'sunos' ]] ; then
    PREFIX='/opt/local/bin/'
  else
    PREFIX=""
  fi
  if [ "$JAVA8" = true ] ; then
    getProcessData8
    echo "$SENDING_DATA"
    getHostData8
    echo "$SENDING_DATA"
    getSlave100Data8
    echo "$SENDING_DATA"
    getSlave200Data8
    echo "$SENDING_DATA"
  else
    getProcessData7
    echo "$SENDING_DATA"
    getHostData7
    echo "$SENDING_DATA"
    getSlave100Data7
    echo "$SENDING_DATA"
    getSlave200Data7
    echo "$SENDING_DATA"
  fi
}

function getStats {
  #sudo -H -u wildfly bash -c '/usr/local/bin/jstat -gc -t 20674' && sudo -H -u wildfly bash -c '/usr/local/bin/jstat -gcutil -t 20674' && sudo -H -u wildfly bash -c "/usr/local/bin/jmap -heap 20674"
  # Timestamp        S0C    S1C    S0U    S1U      EC       EU        OC         OU       PC     PU    YGC     YGCT    FGC    FGCT     GCT
  #       107737.6 8704.0 8704.0 2751.9  0.0   70208.0  32418.3   174784.0   29565.4   36288.0 36022.9      6    0.186   2      0.222    0.408
  JHSTAT=($(getJstat $JHPID | grep -v "Timestamp"))
  JPSTAT=($(getJstat $JPPID | grep -v "Timestamp"))
  if [[ -n "$JSPID1" ]] ; then
    JSTAT1=($(getJstat $JSPID1 | grep -v "Timestamp"))
    JSTAT2=($(getJstat $JSPID2 | grep -v "Timestamp"))
  fi
  checkStats
  if [ "$TESTRUN" = true ] ; then
    echoStats
  else
    sendStats
  fi
}

function checkRunning {
  if [[ -n "$JHPID" ]] ; then
    if ps -p $JHPID  > /dev/null 2>&1
    then 
      getStats
    else
     if [ "$FIRST" = true ]
     then
        FIRST=false
        /opt/jvm-monitor/./create-pid-files.sh
        getPids
        checkRunning
      else
        exit 1
      fi
    fi
  else
    if [ "$FIRST" = true ]
    then
      FIRST=false
      /opt/jvm-monitor/./create-pid-files.sh
      getPids
      checkRunning
    else
      exit 1
    fi
  fi
}

. ./get-platform.sh
if [[ $platform == 'sunos' ]] ; then
  ZABBIX_AGENTD_CONF="/opt/local/etc/zabbix_agentd.conf"
fi
if [[ -n "$1" ]] ; then
  ZABBIX_AGENTD_CONF=$1
fi
if [[ -n "$2" ]] ; then
  TESTRUN=$2
fi
getPids
checkRunning
echo $JPRUN
