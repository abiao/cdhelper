yum install httpd
yum install postgresql
yum install postgresql-server

HTTP_ROOT=/var/www/html
VERSION=5.2.1

PARCEL_DIR=/var/www/html/cdh/$VERSION

cp *parcel* $PARCEL_DIR
cp manefest.jason $PARCEL_DIR

CM_REPO_DIR=/var/www/html/cm/$VERSION
cp cloudera-*.rpm $CM_REPO_DIR
cp oracle*.rpm $CM_REPO_DIR
cd $CM_REPO_DIR
createrepo .

rpm -i cloudera-manager-daemons*
rpm -i cloudera-manager-server*
rpm -i cloudera-manager-server-db*
rpm -i cloudera-agent-*

service cloudera-scm-agent start
service cldouera-scm-server-db start
service cloudera-scm-server start
