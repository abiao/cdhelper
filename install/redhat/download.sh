#!/bin/sh


PARCEL_DIR=http://archive-primary.cloudera.com/cdh5/parcels/latest/
wget ${PARCEL_DIR}/CDH-5.2.1-1.cdh5.2.1.p0.12-el6.parcel
wget ${PARCEL_DIR}/CDH-5.2.1-1.cdh5.2.1.p0.12-el6.parcel.sha1
wget ${PARCEL_DIR}/manifest.json

wget http://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera


CM_RPM_DIR=http://archive.cloudera.com/cm5/redhat/6/x86_64/cm/5/RPMS/x86_64

wget ${CM_RPM_DIR}/cloudera-manager-agent-5.2.1-1.cm521.p0.109.el6.x86_64.rpm
wget ${CM_RPM_DIR}/cloudera-manager-daemons-5.2.1-1.cm521.p0.109.el6.x86_64.rpm
wget ${CM_RPM_DIR}/cloudera-manager-server-5.2.1-1.cm521.p0.109.el6.x86_64.rpm
wget ${CM_RPM_DIR}/cloudera-manager-server-db-2-5.2.1-1.cm521.p0.109.el6.x86_64.rpm
wget ${CM_RPM_DIR}/enterprise-debuginfo-5.2.1-1.cm521.p0.109.el6.x86_64.rpm
wget ${CM_RPM_DIR}/jdk-6u31-linux-amd64.rpm
wget ${CM_RPM_DIR}/oracle-j2sdk1.7-1.7.0+update67-1.x86_64.rpm
