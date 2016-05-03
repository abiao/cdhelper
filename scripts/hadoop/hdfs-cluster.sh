#!/bin/sh

if [ $# -ne 3 ]; then
  echo "Usage: hdfs-cluster.sh start|stop|upgrade|upgrade-stop|rollback user password" 
  exit 1
fi

export PDSH_SSH_ARGS_APPEND="-i /etc/intelcloud/idh-id_rsa"

TOPDIR=/usr/lib/intelcloud/scripts/hadoop
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
  
  echo $wrapcmd
  
  isnamenode=$3
  if [ "$isnamenode" == "true" ]; then
    if [ -f $nodelist ]; then
      # line starts with "primarynamenode:" is used for resouce monitor, we should ignore them
      node=`cat $nodelist|grep -v ^primarynamenode\:`
      pdsh -S -l $user -w $node $wrapcmd
    fi
  else    
	  if [ -f $nodelist ]; then
		pdsh -S -l $user -w ^$nodelist $wrapcmd
	  fi
  fi
}

#start namenode
start_nodes $CONFDIR/namenode "$TOPDIR/hadoop-service.sh namenode $action"  true
echo "Done for Namenode $action."

#start datanodes
start_nodes $CONFDIR/datanodes "$TOPDIR/hadoop-service.sh datanode $action"  false
echo "Done for datanode(s) $action."

#start secondary namenodes
start_nodes $CONFDIR/secondary_namenodes "$TOPDIR/hadoop-service.sh secondary_namenode $action"  false
echo "Done for Secondary Namnode(s) $action."

