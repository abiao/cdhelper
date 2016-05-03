#!/bin/bash

IM_WEBINF_DIR=/usr/lib/intelcloudui/webapps/webui/war/WEB-INF
IM_CONF_DIR="$IM_WEBINF_DIR/conf"
IM_DATA_DIR="$IM_WEBINF_DIR/data"
VERSION=$(cat /etc/intelcloud/VERSION|grep "Release Version"|sed s/.*\:\//g|tr -d " ")

if [ `echo "$VERSION 2.29" | awk '{if ($1 > $2) print "true"; else print "false"}'` = "true" ]; then
oldpackagename=`rpm -qa | grep intelcloudui`.rpm
upgradetool=""
if [ -f /etc/redhat-release ]; then
upgradetool="yum"
installopt="-y"
else
upgradetool="zypper"
installopt="-n"
fi
echo -e "This script will upgrade Intel Manager offline.\nStopping Intel manager service...";
service intel-manager stop;
sleep 5;
if [ `netstat -nlp | grep 9443| wc -l` == 0 ]; then
echo -e "Intel Manager stopped successfully\nBacking up Intel Manager data...";

#This will work only for 2.3, as resourcemonitor was a separate service. In case of 2.4.x, the errors will be suppressed.
service resourcemonitor stop &> /dev/null;
chkconfig resourcemonitor off &> /dev/null;


rm -rf /tmp/xmls;
if [ `echo $oldpackagename| grep "intelcloudui-23" | wc -l` == 1 ]; then
mkdir /tmp/xmls;
cp -R $IM_CONF_DIR /tmp/xmls/v1;
else
cp -R $IM_CONF_DIR /tmp/xmls; 
fi
if [ $? == 0 ]; then
echo "Configuration files backup successful"; 
fi
tar -cf /tmp/agent_bkup.tar /etc/intelcloud/im-agent &>/dev/null;
else 
echo -e "Service is not stopped.\nPlease stop it manually and retry"; 
exit 1;
fi

if [ $? == 0 ]; then  
echo "Agent Backup successful";
echo "Upgrading the package...";
rpm -Uvh /tmp/intelmanager-rpms/intelcloudui-251*.rpm;

else
echo "Backup of the data failed.."; 
exit 1; 
fi

if [ $? == 0 ]; then
echo -e "Package upgrade successful.\nUpgrading agent...";
find /etc/intelcloud/im-agent -type f -print| grep -v conf | xargs rm -rf; rm -rf /etc/intelcloud/im-agent/lib;
cp -R /usr/lib/intelcloudui/agent/* /etc/intelcloud/im-agent;
else
echo "RPM package upgrade failed.."; 
exit 1; 
fi

if [ $? == 0 ]; then
echo -e "Agent upgrade successful.\nUpgrading User Data...";
cd $IM_WEBINF_DIR/classes;
java -agentpath:/usr/lib/intelcloudui/bin/libagent.so -cp /usr/lib/intelcloudui/webapps/webui/gwt_addins/gwt-user.jar:$IM_WEBINF_DIR/classes:$IM_WEBINF_DIR/tmp-classes  com.intelcloud.webui.server.utils.UpgradeIMBin;
echo "Upgrading IDH configuration data";
cd $IM_WEBINF_DIR/classes;
java -agentpath:/usr/lib/intelcloudui/bin/libagent.so -cp $IM_WEBINF_DIR/classes:$IM_WEBINF_DIR/tmp-classes/:/usr/lib/intelcloudui/webapps/webui/gwt_addins/gwt-user.jar:$IM_WEBINF_DIR/lib/commons-io-1.4.jar com.intelcloud.webui.server.utils.UpgradeHadoopParams -u;
else
echo "Agent was not upgraded properly";
exit 1;
fi


if [ $? == 0 ]; then 
#hmon cleanup
rm -rf /etc/intelcloud/conf/hmon/;

#Write md5sum to agent
agent="/etc/intelcloud/im-agent/conf/agent"
val=`md5sum /etc/intelcloud/im-agent/agent.jar | awk '{print $1}'`
oldval=`grep 'md5sum' "$agent"`
newval="#md5sum="
newval=$newval$val
if [ -n "$oldval" ]; then
 sed -i "s/$oldval/$newval/g" "$agent";
else
 echo $newval >> $agent;
fi

#change config to yes in binded_ip.csv
{ rm -f /usr/lib/intelcloud/binded_ip.csv &&
    awk '/config/{gsub(/no/, "yes")};{print}' > /usr/lib/intelcloud/binded_ip.csv
} < /usr/lib/intelcloud/binded_ip.csv;

if [ `cat /usr/lib/intelcloud/binded_ip.csv | grep "config.*yumclient" | wc -l` -eq 0 ]; then
echo "Config client entries missing in binded_ip.csv. Adding them..."
echo -e "configosyumclient,yes\nconfigidhyumclient,yes" >> /usr/lib/intelcloud/binded_ip.csv
fi

echo "Upgrading Smart Tuner..."
service smart-tuner stop &>/dev/null && $upgradetool $installopt update smarttuner &>/dev/null
sleep 2;
service smart-tuner start;
echo "Starting Intel Manager Service...";
service intel-manager start; 
echo -e "To finalize the upgrade process, please login to Intel Manager with Administrator Privilleges and navigate to Configuration->Nodes->Node and Click on \"Provisioning Service Properties.\"";
else
echo -e "bins upgrade failed\nReverting to old package and data files";
rpm -Uvh --oldpackage /tmp/intelmanager-rpms/$oldpackagename;
rm -rf $IM_DATA_DIR/*;
tar -C / -jxf $IM_WEBINF_DIR/snapshot/config-IM-upgrade.tar.bz2;
tar -C / -xf /tmp/agent_bkup.tar;
rm -rf $IM_CONF_DIR;
cp -R /tmp/xmls $IM_CONF_DIR;
exit 1
fi
else
echo "The installed version $VERSION is not supported for upgrade";
exit 1;
fi
