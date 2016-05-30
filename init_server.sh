#!/bin/sh
# disable and overwrite
echo "SELINUX=disabled" > /etc/selinux/config

#echo never > /sys/kernel/mm/redhat_transparent_hugepage/defrag
echo never > /sys/kernel/mm/transparent_hugepage/defrag

chkconfig iptables off
setenforce 0

echo "vm.swappiness=0" >> /etc/sysctl.conf

yum install ntp
service ntpd start
chkconfig ntpd on

/etc/init.d/network restart
init 6

