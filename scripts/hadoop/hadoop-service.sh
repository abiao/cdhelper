#!/bin/sh
#usage: hadoop-service [namenode|datanode|secondary_namenode|jobtracker|tasktracker] [start|stop|restart|status]
service=$1
action=$2
command=""

case $service in
"namenode")
  case $action in
  "upgrade")
  command="crm resource unmanage namenode; service hadoop-namenode upgrade"
  ;;
  "upgrade-stop")
  command="crm resource manage namenode; service hadoop-namenode stop"
  ;;
  "rollback")
  command="crm resource unmanage namenode; service hadoop-namenode rollback; crm resource manage namenode; crm resource start namenode"
  ;;
  "finalizeUpgrade")
  command="crm resource manage namenode; crm resource start namenode"
  ;;
  *)
  command="crm resource manage namenode; crm resource $action namenode"
  ;;
  esac
  
  ;;
"datanode")
  case $action in
  "start" | "upgrade" | "rollback")
  command="service hadoop-datanode start"
  ;;
  "stop" | "upgrade-stop")
  command="service hadoop-datanode stop"
  ;;
  *)
  command="service hadoop-datanode $action"
  ;;
  esac
  ;;
"secondary_namenode")
  case $action in
  "start" | "upgrade" | "rollback")
  command="service hadoop-secondarynamenode start"
  ;;
  "stop" | "upgrade-stop")
  command="service hadoop-secondarynamenode stop"
  ;;
  *)
  command="service hadoop-secondarynamenode $action"
  ;;
  esac
  ;;
"jobtracker")
  command="crm resource $action jobtracker"
  ;;
"tasktracker")
  command="service hadoop-tasktracker $action"
  ;;
"resourcemanager")
  command="service  $action"
  ;;
"nodemanager")
  command="service  $action"
  ;;
esac

#remove ANSI color
if [ -n "$command" ]; then
  bash -c "$command" | perl -pe 's/\r|\e\[?.*?[\@-~]//g';  exit ${PIPESTATUS[0]}
fi
