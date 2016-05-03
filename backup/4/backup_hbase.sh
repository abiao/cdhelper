#!/bin/sh
mkdir hbase

for t in `cat t.txt`; do
	hadoop fs -get /hbase/$t hbase;
done
