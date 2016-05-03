#!/bin/sh
source ../../conf/set.sh

yum install createrepo
yum install httpd

HTTP_ROOT=/var/www/html

PARCEL_DIR=/var/www/html/cdh/$VERSION

cp *parcel* $PARCEL_DIR
cp manefest.jason $PARCEL_DIR

CM_REPO_DIR=${HTTP_ROOT}/repo/cm/$VERSION
CDH_REPO_DIR=${HTTP_ROOT}/repo/cdh/$VERSION

cp *.rpm $CM_REPO_DIR
#cp oracle*.rpm $CM_REPO_DIR
cd $CM_REPO_DIR
createrepo .

rpm -i oracle*.rpm

echo "# Copy this file to dir /etc/yum.repos.d 
[CDH]
name=CDH repo
baseurl=http://${CM_HOSTNAME}/repo/cdh/$VERSION
enabled=true
gpgcheck=false

[CM]
name=CM repo
baseurl=http://{CM_HOSTNAME}/repo/cm/$VERSION
enabled=true
gpgcheck=false
"

rpm -i cloudera-manager-daemons*
rpm -i cloudera-manager-server*
rpm -i cloudera-manager-server-db*
rpm -i cloudera-agent-*

service cloudera-scm-agent start
service cldouera-scm-server-db start
service cloudera-scm-server start
