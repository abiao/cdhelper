#!/bin/bash

printUsage() {
  echo "USAGE: 
  ./uninstall.sh [-u|--username user] ALL|all
  ./uninstall.sh [-u|--username user] node1 node2 node3 ...
  "; 
}

USER=""
retry_times=0

while [ $# -gt 0 ]
do
    case "$1" in
    -u|--username) USER="$2"; shift;;
    --help)
        printUsage
        exit 0;;
    -*)
        printUsage
        exit 1;;
    *)  break;;
    esac
    shift
done;
echo $USER
if [ $# == 0 ]; then
  printUsage
  exit 1; 
fi

source /etc/intelcloud/installation.conf
source /usr/lib/intelcloudui/webapps/webui/war/WEB-INF/scripts/setenv.sh

ask() {
  # USAGE: ask foo "enter value for foo"
  NAME=$1;shift
  read -r -p "$@" VAR
  eval "$NAME='$VAR'"
}

ssh_sudo() {
  # USAGE: ssh_sudo host1 "some_shell_command"
  #   username will be asked
  #   password will be asked if it is required
  HOST=$1
  if [ "$USER"x == ""x ]; then
    echo ask USER "username of $HOST: "
  fi

  COMMAND=$2
  ssh_runas_root_script "$HOST" root "$COMMAND"
}

do_clear_node() {
  node=$1

  echo "execute do_clear_node"
  # check service
  ssh_sudo $node '
    function continue_ask {
      # interactive asking seems to be broken in sudo mode
      return 0
    }

    RETVAL=0
    echo -e "\n************************************************************************************************************"
    #echo "Cleaning softwares such as hadoop hbase hive zookeeper oozie sqoop mahout flume pig hcatalog ganglia puppet nginx intel-manager for `hostname`..."
    echo "Cleaning softwares for `hostname`..."
    echo "************************************************************************************************************"
    continue_ask
    RETVAL=$?
    [ $RETVAL -ne 0 ] && exit $RETVAL

    services="hadoop-namenode hadoop-datanode hadoop-jobtracker hadoop-tasktracker hadoop-secondarynamenode hbase-master hbase-regionserver hbase-thrift hive-metastore hive-server '$MYSQL_NAME' zookeeper-server oozie webhcat-server"
    for srvc in $services
    do
      if [ -e /etc/init.d/$srvc ];then
	echo "Uninstalling $srvc ..."
      	if service $srvc status >/dev/null 2>&1; then
        	echo "ERROR: Service $srvc is running. Please stop it first."
        	RETVAL=1
      	fi
      fi
    done
    [ $RETVAL -ne 0 ] && exit $RETVAL

    services="puppet puppetmaster nginx pacemaker corosync intel-manager sqoop-metastore flume-node flume-master gmond gmetad nagios im-agent rrdcached"
    for srvc in $services
    do
      service $srvc stop >/dev/null 2>&1
    done
    service resourcemonitor force-stop >/dev/null 2>&1

    rm -f /etc/init.d/im-agent >/dev/null 2>&1
    rpm -e --noscripts sqoop-metastore >/dev/null 2>&1
    # check repo
    [ "'$REPO_BIN'" == "yum" ] && yum-complete-transaction >/dev/null 2>&1
    '$REPO_BIN' clean '$REPO_CLEANALL_OPT' >/dev/null 2>&1
    '$REPO_BIN' '$REPO_YES_OPT' -q remove puppet >/dev/null 2>&1
    if [ "$?" != "0"  ]; then 
      echo -e "\nERROR: Cannot connect to the IDH or OS '$REPO_BIN' repository. "
      echo "Verify the repo files are valid and that the node can connect to the software repos."
      exit 3
    fi

    if [ "'$REPO_BIN'" == "zypper" ]; then
      rpm -e `rpm -qa | grep zookeeper-server` --noscripts > /dev/null 2>&1
    fi

    for comp in pacemaker corosync hadoop hbase hive mysql zookeeper sqoop mahout flume pig hcatalog oozie ganglia nagios puppet nginx ftpoverhdfs
    do
      echo "Uninstalling $comp ..."
      '$REPO_BIN' '$REPO_YES_OPT' -q remove $comp >/dev/null 2>&1
      rm -rf /etc/$comp /usr/lib/$comp /var/log/$comp /var/lib/$comp
    done

    echo "Uninstalling other related packages"
    '$REPO_BIN' '$REPO_YES_OPT' -q remove hadoop-doc hbase-doc oozie-client smarttuner libganglia ganglia-gmetad ganglia-gmond ganglia-web ganglia-gmond-modules-python nagios-plugins >/dev/null 2>&1
    '$REPO_BIN' '$REPO_YES_OPT' -q remove hadoop-debuginfo > /dev/null 2>&1

    echo "Uninstalling Intel Manager for Apache Hadoop"
    if [ "'$REPO_BIN'" == "yum" ]; then
      '$REPO_BIN' '$REPO_YES_OPT' -q remove idh-management intelcloudui >/dev/null 2>&1
    else
      rpm -e `rpm -qa | grep -E "idh|intelcloudui"` >/dev/null 2>&1
    fi

    echo "Removing related directories ..."
    rm -rf /etc/intelcloud
    rm -rf /usr/lib64/ganglia
    rm -rf /usr/lib/intelcloud
    rm -rf /usr/lib/deploy
    rm -rf /usr/lib/resourcemonitor
    rm -rf /usr/lib/intelcloudui
    rm -rf /hadoop/drbd/mysql
    rm -rf /var/zookeeper
    rm -rf /var/spool/nagios/nagios.cmd
    rm -rf /var/cache/'$REPO_BIN'
    rm -rf '$HTTP_DIR'/logs
    rm -rf /var/log/resmon

    # recovery repo files
    cd '$REPO_CONFDIR'
    rm -rf os.repo* idh.repo*
    rename .repo.bak .repo *
    cd - >/dev/null

    echo "Uninstallation for '$node' finished."
  '
  
  return $?
}

clear_node() {
  # USAGE: clear_node host1
  USER=""
  node=$1
  do_clear_node $node

  retval=$?
  if [ "$retval" != "0" -a $retry_times -lt 1 ]; then
    USER=""
    retry_times=$(($retry_times+1))
    do_clear_node $node
    retval=$?
  fi
    
  if [ "$retval" != "0" ]; then
    return $retval
  fi
}

SERVER_HOSTNAME=`hostname`
SELF_INCLUDED=false
HA_ENABLED=false
CLUSTER_CONF_DIR=/etc/puppet/config
HA_SCRIPT_DIR=/usr/lib/intelcloudui/tools/ha

if [ "$1" == "ALL" ] || [ "$1" == "all" ]; then
  if [ -f $CLUSTER_CONF_DIR/role.csv ]; then
    NODELIST="`cat $CLUSTER_CONF_DIR/role.csv | sed 's/,.*//g'`"
  else
    echo "WARN: Cannot find role configuration file $CLUSTER_CONF_DIR/role.csv"
    NODELIST="$SERVER_HOSTNAME"
  fi
else
  NODELIST=$*
fi

if [ "$OS_DISTRIBUTOR" == "sles" ]; then
  MYSQL_NAME="mysql"
  HA_CLEAN_SCRIPT=$HA_SCRIPT_DIR/SLES/clean_single_settings.sh
else
  MYSQL_NAME="mysqld"
  HA_CLEAN_SCRIPT=$HA_SCRIPT_DIR/CentOS/clean_single_settings.sh
fi

# Check if HA is enabled
if [ -f $CLUSTER_CONF_DIR/cluster.csv ]; then
  if grep -E "^components.*,ha($|,)" $CLUSTER_CONF_DIR/cluster.csv >/dev/null; then
    HA_ENABLED=true
  else
    HA_ENABLED=false
  fi
fi

FAILNODES=""

for eachnode in $NODELIST
do
  # Clean HA configuration of nodes which have HA roles.
  USER=""
  if [ "$HA_ENABLED" == "true" ]; then
  echo "Cleaning HA configurations for $eachnode"
    client_hostname="`ssh_sudo $eachnode hostname`"
    ha_role_regexp="^$client_hostname.*(hadoop_namenode|hadoop_backup_namenode|hadoop_jobtracker|hadoop_backup_jobtracker|pacemaker)"
    if [ -f $CLUSTER_CONF_DIR/role.csv ] && grep -E $ha_role_regexp $CLUSTER_CONF_DIR/role.csv > /dev/null; then
      if [ -f $HA_CLEAN_SCRIPT ]; then
        sh $HA_CLEAN_SCRIPT clean $eachnode
        [ $? -ne 0 ] && continue
      else
        echo "ERROR: Cannot find HA clean script $HA_CLEAN_SCRIPT"
        exit 1
      fi
    fi
  fi

  if [ "$(hostname)" == "$eachnode" ]; then
    SELF_INCLUDED="true"
    continue
  fi

  retry_times=0;
  if ! clear_node $eachnode 
  then
      FAILNODES="$FAILNODES $eachnode"
  fi
done

if [ "$SELF_INCLUDED" == "true" ]; then
  USER=""
  echo "WARN: Please make sure all the other nodes of the cluster have been uninstalled before the management node."
  retry_times=0;
  if ! clear_node localhost
  then
      name=$(hostname)
      FAILNODES="$FAILNODES $name"
  fi
fi

if [ "$FAILNODES"x != ""x ]; then
    echo "Error: Intel Distribution for Apache Hadoop Software was not successfully uninstalled on the following nodes: $FAILNODES. Consequently, all or some of the Intel Distribution RPMs may still be installed on those machines."
fi
