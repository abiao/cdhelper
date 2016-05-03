#!/bin/sh

if [ $# -ne 3 ]; then
  echo "Usage: hive-cluster.sh start|stop username password"
  exit 1
fi

export PDSH_SSH_ARGS_APPEND="-i /etc/intelcloud/idh-id_rsa"

TOPDIR=/usr/lib/intelcloud/scripts/hive
CONFDIR=/etc/intelcloud/conf

action=$1
user=$2
password=$3

function start_nodes {
  nodelist=$1
  cmd=$2
  wrapcmd=$cmd
  if [ "$user" != "root" ]; then
    wrapcmd="echo '$password' | sudo -S -p '' $cmd"
  fi
  if [ -f $nodelist ]; then
    pdsh -S -l $user  -w ^$nodelist $cmd
  fi
}

if [ "$action" == "start" ]; then
  #start mysql and metastore
  start_nodes $CONFDIR/namenode "$TOPDIR/hive-metastore-service.sh $action"
#  echo "Done for MySQL and Hive metastore $action."

  #start hive thrift servers
  start_nodes $CONFDIR/hive_thrifts "service hive-server $action"
#  echo "Done for Hive thrift server(s) $action."
fi

if [ "$action" == "stop" ]; then
  #start hive thrift servers
  start_nodes $CONFDIR/hive_thrifts "service hive-server $action"
#  echo "Done for Hive thrift server(s) $action."

  #start mysql and metastore
  start_nodes $CONFDIR/namenode "$TOPDIR/hive-metastore-service.sh $action"
#  echo "Done for MySQL and Hive metastore $action."
fi 
echo "Done for Hive server(s) $action."
