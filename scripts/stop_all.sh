#!/bin/sh
sudo service hue stop
sudo service sqoop-metastore stop
sudo /sbin/service sqoop2-server stop
sudo service flume-node stop
sudo service flume-master stop
sudo service flume-ng-agent stop
sudo service oozie stop
sudo service hiveserver2 stop
sudo service hive-metastore stop
sudo service hbase-thrift stop
sudo service hbase-master stop
sudo service hadoop-hbase-regionserver stop
sudo service hadoop-0.20-mapreduce-jobtracker stop
sudo service hadoop-0.20-mapreduce-tasktracker stop
sudo service hadoop-mapreduce-historyserver stop
sudo service hadoop-yarn-resourcemanager stop
sudo service hadoop-yarn-nodemanager stop
sudo service hadoop-httpfs stop
sudo service hadoop-hdfs-namenode stop
sudo service hadoop-hdfs-secondarynamenode stop
sudo service hadoop-hdfs-datanode stop
sudo service zookeeper-server stop
sudo service zookeeper stop

for x in `cd /etc/init.d ; ls hadoop-*` ; do sudo service $x stop ; done
echo "after stop: java->"
ps -aef | grep java
