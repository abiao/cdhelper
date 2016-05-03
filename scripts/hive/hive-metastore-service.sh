#!/bin/sh
#usage: hive-metastore-service [start|stop|restart|status]
command=$1
crm resource $command hive_group
