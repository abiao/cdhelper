wget https://archive.cloudera.com/cm5/installer/latest/cloudera-manager-installer.bin
chmod u+x cloudera-manager-installer.bin
sudo ./cloudera-manager-installer.bin

## Install Cloudera Manager packages from a local repository:
## sudo ./cloudera-manager-installer.bin --skip_repo_package=1

/usr/share/cmf/uninstall-cloudera-manager.sh
#cd /etc/yum.repos.d
#wget http://archive-primary.cloudera.com/cm5/redhat/6/x86_64/cm/cloudera-manager.repo
#wget http://archive-primary.cloudera.com/cdh5/redhat/6/x86_64/cdh/cloudera-cdh5.repo


