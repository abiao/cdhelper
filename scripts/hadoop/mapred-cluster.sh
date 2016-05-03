#!/bin/sh

if [ $# -ne 3 ]; then
  echo "Usage: mapred-cluster.sh start|stop user password"
  exit 1
fi

export PDSH_SSH_ARGS_APPEND="-i /etc/intelcloud/idh-id_rsa -o SendEnv=IDH_ARG1"

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
    export IDH_ARG1=$password
    wrapcmd="echo \"\$IDH_ARG1\" | sudo -S -p '' $cmd"
  fi
  echo $wrapcmd
  
  isjobtracker=$3
  if [ "$isjobtracker" == "true" ]; then
    if [ -f $nodelist ]; then
      # line starts with "jobtracker:" is used for resouce monitor, we should ignore them
      node=`cat $nodelist|grep -v ^jobtracker\:`
      pdsh -S -l $user -w $node $wrapcmd
  fi
  else  
	  if [ -f $nodelist ]; then
		pdsh -S -l $user -w ^$nodelist $wrapcmd
	  fi
  fi
}

#start namenode
start_nodes $CONFDIR/jobtracker "$TOPDIR/hadoop-service.sh jobtracker $action" true
echo "Done for Jobtracker $action."

#start datanodes
start_nodes $CONFDIR/tasktrackers "$TOPDIR/hadoop-service.sh tasktracker $action" false
echo "Done for Tasktracker(s) $action."

