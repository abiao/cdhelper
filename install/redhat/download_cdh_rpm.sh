#!/bin/sh
RPM_URL_ROOT=http://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/5/RPMS/x86_64/

function rpm_list() {
	curl $RPM_URL_ROOT | grep rpm | grep "href" | awk  'BEGIN {FS = "\""} {print $8}'
}

for rpm in `rpm_list` ; do
	echo download $rpm
done;
