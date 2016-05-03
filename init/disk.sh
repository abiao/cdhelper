#!/bin/sh
disk_list="/dev/sdb /dev/sdc /dev/sdd /dev/sde"
dno=2
for d in $disk_list;
do
	echo $d
	mkfs -t ext3 $d <<EOD
y
EOD
	mdir=/mnt/data$dno
	echo $mdir
	mkdir $mdir
	dno=`expr $dno + 1`
	mount -t ext3 $d $mdir
	echo "$d $mdir ext3 defaults,noatime 0" >> /etc/fstab
done

