#!/bin/sh
RPM_URL_ROOT=http://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/5/RPMS/x86_64/

function rpm_list() {
	curl $RPM_URL_ROOT | grep rpm | grep "href" | awk  'BEGIN {FS = "\""} {print $8}'
}

for rpm in `rpm_list` ; do
	echo download $rpm
done;



#!/bin/bash
url="http://archive.cloudera.com/cm5/redhat/6/x86_64/cm/5/RPMS/x86_64/"

files=()
# populate the array using a while loop and process substitution (direct piping will not work)
while read line
do
  files+=("$line")
done

done <<(curl -s $url | grep unknow | awk -F '"' '{print $8}')

for f in $files do
echo $url/$f
done