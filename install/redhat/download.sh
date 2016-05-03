#!/bin/sh


PARCEL_DIR=http://archive-primary.cloudera.com/cdh5/parcels/latest/
PARCEL_FILE=CDH-5.3.0-1.cdh5.3.0.p0.30-el6.parcel
#wget ${PARCEL_DIR}/${PARCEL_FILE}
#wget ${PARCEL_DIR}/${PARCEL_FILE}.sha1
#wget ${PARCEL_DIR}/manifest.json

#wget http://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera

CM_RPM_DIR=http://archive.cloudera.com/cm5/redhat/6/x86_64/cm/5/RPMS/x86_64
CDH_RPM_DIR=http://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/5/RPMS/x86_64

#wget ${CM_RPM_DIR}/cloudera-manager-agent-5.2.1-1.cm521.p0.109.el6.x86_64.rpm
#wget ${CM_RPM_DIR}/cloudera-manager-daemons-5.2.1-1.cm521.p0.109.el6.x86_64.rpm
#wget ${CM_RPM_DIR}/cloudera-manager-server-5.2.1-1.cm521.p0.109.el6.x86_64.rpm
#wget ${CM_RPM_DIR}/cloudera-manager-server-db-2-5.2.1-1.cm521.p0.109.el6.x86_64.rpm
#wget ${CM_RPM_DIR}/enterprise-debuginfo-5.2.1-1.cm521.p0.109.el6.x86_64.rpm
#wget ${CM_RPM_DIR}/jdk-6u31-linux-amd64.rpm
#wget ${CM_RPM_DIR}/oracle-j2sdk1.7-1.7.0+update67-1.x86_64.rpm

function download_file_in_page() {
	PAGE=$1
	FILE_EXT=$2
	if [ "$FILE_EXT" = "" ]; then
		wget -c -r -nd -np -k -L $PAGE
	else
		wget -c -r -nd -np -k -L -A $FILE_EXT $PAGE
	fi
}

download_file_in_page $CM_RPM_DIR rpm
download_file_in_page http://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/5/RPMS/noarch rpm
download_file_in_page $CDH_RPM_DIR rpm 
