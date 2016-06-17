#!/bin/sh
#source ../../conf/set.sh
VERSION=5.5.4


yum install -y createrepo
yum install -y httpd
yum install -y postgresql
yum install -y postgresql-server

# yum install -y cloudera-manager-daemons cloudera-manager-server cloudera-manager-server-db-2.x86_64
service postgresql initdb
service postgresql start

HTTP_ROOT=/var/www/html

PARCEL_DIR=/var/www/html/cdh/$VERSION
mkdir -p $PARCEL_DIR
mv *parcel* $PARCEL_DIR
mv manefest.jason $PARCEL_DIR

CM_REPO_DIR=/var/www/html/cm/$VERSION
mkdir -p $CM_REPO_DIR
mv *.rpm $CM_REPO_DIR
cd $CM_REPO_DIR
createrepo .

rpm -i oracle*.rpm

# 
#echo [myrepo]
#name=repo
#baseurl=http://172.31.46.113/cm/
#enabled=true
#gpgcheck=false
#"

rpm -i cloudera-manager-daemons*
rpm -i cloudera-manager-server*
rpm -i cloudera-manager-server-db*
rpm -i cloudera-agent-*

service cloudera-scm-agent start
service cloudera-scm-server-db start
service cloudera-scm-server start
