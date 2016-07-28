#!/bin/bash

# Configurables
TMP="/tmp"
PIDF="/tmp/pids"

# Non-Configurables
TEMP_OUT=$TMP/test-jps-output.txt

# Querying plattform
. /opt/jvm-monitor/./get-platform.sh

# Getting running jvms
if [[ $platform == 'sunos' ]]; then
  /opt/local/bin/sudo /opt/local/java/openjdk7/bin/jps -v > $TEMP_OUT
else
  sudo -H -u wildfly bash -c "/usr/local/bin/jps -v" > $TEMP_OUT
fi

cat $TEMP_OUT
# Parsing process strings into array
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
#/opt/local/java/openjdk7/bin/jstat -gc -t $i
JPIDS=($(<$TEMP_OUT))
rm -f $TEMP_OUT
IFS=$SAFEIFS

# Storing respective jvm process ids in the respective variable
for i in "${JPIDS[@]}"
do
  TMP=$(echo $i | grep "Process Controller" | cut -d " " -f 1)
  if [ -n "$TMP" ]
  then
    JPPID=$TMP
  fi
  TMP=$(echo $i | grep "Host Controller" | cut -d " " -f 1)
  if [ -n "$TMP" ]
  then
    JHPID=$TMP
  fi
  TMP=$(echo $i | grep "slave" | grep "100" | cut -d " " -f 1)
  if [ -n "$TMP" ]
  then
    JSPID1=$TMP
  fi
  TMP=$(echo $i | grep "slave" | grep "200" | cut -d " " -f 1)
  if [ -n "$TMP" ]
  then
    JSPID2=$TMP
  fi
done

# Storing variables to files
if [ -n "$JPPID" ]
then
  echo "$JPPID" > "$PIDF/process-controller.pid"
fi
if [ -n "$JHPID" ]
then
  echo "$JHPID" > "$PIDF/host-controller.pid"
fi
if [ -n "$JSPID1" ]
then
  echo "$JSPID1" > "$PIDF/slave-100.pid"
fi
if [ -n "$JSPID2" ]
then
  echo "$JSPID2" > "$PIDF/slave-200.pid"
fi
