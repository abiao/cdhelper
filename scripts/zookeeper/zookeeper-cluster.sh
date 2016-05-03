#!/bin/sh

if [ $# -ne 3 ]; then
  echo "Usage: zookeeper-cluster.sh start|stop username password"
  exit 1
fi

export PDSH_SSH_ARGS_APPEND="-i /etc/intelcloud/idh-id_rsa"

TOPDIR=/usr/lib/intelcloud/scripts/zookeeper
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
    pdsh -S -l $user -w ^$nodelist $wrapcmd
  fi
}

#start quorum
start_nodes $CONFDIR/zookeepers "$TOPDIR/zookeeper-service.sh zookeeper $action"
echo "Done for zookeeper(s) $action."
