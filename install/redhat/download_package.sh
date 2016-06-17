#!/bin/sh
VERSOIN=5.5.4
## URL must end with '/' 
wget -c -r -nd -np -k -L -A rpm http://archive.cloudera.com/cm5/redhat/6/x86_64/cm/$VERSION/RPMS/x86_64/

wget -c -r -nd -np -k -L -A *el6* http://archive-primary.cloudera.com/cdh5/parcels/$VERSION/
