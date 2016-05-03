#!/bin/sh
source ../../conf/set.sh

echo "# Copy this file to dir /etc/yum.repos.d 
[CDH]
name=CDH repo
baseurl=http://${CM_HOSTNAME}/repo/cdh/${CDH_VERSION}
enabled=true
gpgcheck=false

[CM]
name=CM repo
baseurl=http://${CM_HOSTNAME}/repo/cm/${CM_VERSION}
enabled=true
gpgcheck=false
" > /etc/yum.repos.d/cdh.repo
