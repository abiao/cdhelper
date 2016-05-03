#!/bin/sh
#usage: hbase-service [master|regionserver|thrift|thrift-kerberos] [start|stop|restart|status|force-stop]
service=$1
action=$2
command=""

case $service in
"master")
  command="service hbase-master $action"
  ;;
"active_master")
  #example hbase-service active_master stop true keytab principal
  #example hbase-service active_master stop false
  use_kerberos=$3;
  keytab=$4;
  principal=$5;
  if [ "$use_kerberos" == "true" ]; then
    command="kinit -kt $keytab $principal; ksu hbase -n ${principal} -e /usr/lib/hbase/bin/hbase --config /etc/hbase/conf master stop"
  else
    command="su -s /bin/sh hbase -c \"/usr/lib/hbase/bin/hbase --config /etc/hbase/conf master stop\""
  fi
  ;;

"regionserver")
  command="service hbase-regionserver $action"
  ;;
"thrift")
  command="service hbase-thrift $action"
  ;;
"thrift-kerberos")
  command="fqdn=\`hostname -f\`; su -s /bin/sh hbase -c \"kinit -kt /etc/hbase.keytab hbase/\$fqdn\"; service hbase-thrift $action" 
  ;;
esac

#remove ANSI color
bash -c "$command" | perl -pe 's/\r|\e\[?.*?[\@-~]//g';  exit ${PIPESTATUS[0]}
