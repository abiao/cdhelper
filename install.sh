#!/bin/bash
giveinvalidargumentwarning(){
    echo "USAGE: 
    ./install.sh [options]
            -n,--network_interface={name of NIC to bind intel manager}
            -m,--mode={dialog|commandline|silent}
     	    -l,--accept_jdk_license={accept|disagree}
            -i,--idhrepo={Enter 1 or 2. The values mean the following: 1.set up an entry for an existing repo; 2.nothing to do,already set up a repo}
     	    -o,--osrepo={Enter 1, 2 or 3. The values mean the following: 1.nothing to do,already set up a repo 2.set up an entry for an existing repo 3.remove existing all entries and set up an entry for an existing repo}
	    -f,--firewall_selinux_setting={Enter 1 or 2. The values mean the following: 1.disable firewall 2.nothing to do}"
    exit 1
}
path=`dirname $0`
networkinterfaceflag=1
modeflag=1
acceptjdklicenseflag=1
idhrepoflag=1
osrepoflag=1
firewallselinuxsettingflag=1
for argu in "$@"
do 
case $argu in 
     -n=*|--network_interface=*)
	networkinterfaceval=`echo $argu|sed 's/.*=//'`
	networkinterfaceflag=0
     ;;
     -m=*|--mode=*)
     	modeval=`echo $argu|sed 's/.*=//'`
	modeflag=0
     ;;
     -l=*|--accept_jdk_license=*)
     	acceptjdklicenseval=`echo $argu|sed 's/.*=//'`
	acceptjdklicenseflag=0
     ;;
     -i=*|--idhrepo=*)
	idhrepoval=`echo $argu|sed 's/.*=//'`
	idhrepoflag=0
     ;;
     -o=*|--osrepo=*)
	osrepoval=`echo $argu|sed 's/.*=//'`
	osrepoflag=0
     ;;
     -f=*|--firewall_selinux_setting=*)
	firewallselinuxsettingval=`echo $argu|sed 's/.*=//'`
	firewallselinuxsettingflag=0
     ;;
     -help)
	giveinvalidargumentwarning
     ;;
     *)
	giveinvalidargumentwarning
	
	;;
esac
done
#echo $networkinterfaceval
#echo $modeval
#echo $acceptjdklicenseval
#echo $idhrepoval
#echo $osrepoval
#echo $firewallselinuxsettingval
conf=$path/ui-installer/conf
#conf='conf'
#echo $conf
function replacewithcommandargs(){
	text=$1
	replaceval=$2
	islastconfig=$3
	lineno=`sed -n -e '/'"$text"'/=' $conf`
	if [ -n "$lineno" ]; then
	     if [ "$islastconfig" ==  1 ]; then
             	sed -i  ''"$lineno"'d' $conf
                sed -i  ''"$lineno"' i'"$text"'='"$replaceval"'' $conf
	     else
                sed -i  ''"$lineno"' i'"$text"'='"$replaceval"'' $conf
		sed -i '$d' $conf 
	     fi

	else
	    echo "ui-installer/conf missing "$text
	    exit 1
	fi


}
islast=1
if [ "$networkinterfaceflag" -eq 0 ]; then
#	networkinterfacelineno=`sed -n -e '/network_interface/=' $conf`
	#sed -i  ''"$networkinterfacelineno"'d' $conf 
	#sed -i  ''"$networkinterfacelineno"' inetwork_interface='"$networkinterfaceval"'' $conf
	replacewithcommandargs  "network_interface" $networkinterfaceval $islast 
fi
if [ "$modeflag" -eq 0 ]; then 
	#modelineno=`sed -n -e '/mode/=' $conf`
	#sed -i ''"$modelineno"'d' $conf
	#sed -i ''"$modelineno"' imode='"$modeval"'' $conf
        replacewithcommandargs "mode" $modeval $islast
fi
if [ "$acceptjdklicenseflag" -eq 0 ]; then
#	acceptjdklicenselineno=`sed -n -e '/accept_jdk_license/=' $conf`
#	sed -i ''"$acceptjdklicenselineno"'d' $conf
#	sed -i ''"$acceptjdklicenselineno"' iaccept_jdk_license='"$acceptjdklicenseval"'' $conf
	replacewithcommandargs "accept_jdk_license" $acceptjdklicenseval $islast
fi
if [ "$idhrepoflag" -eq 0 ]; then  
#	idhrepolineno=`sed -n -e '/how_to_setup_idh_repo/=' $conf`
#	sed -i ''"$idhrepolineno"'d' $conf
#	sed -i ''"$idhrepolineno"' ihow_to_setup_idh_repo='"$idhrepoval"'' $conf
        replacewithcommandargs "how_to_setup_idh_repo" $idhrepoval $islast
fi
if [ "$osrepoflag" -eq 0 ]; then 
#	osrepolineno=`sed -n -e '/how_to_setup_os_repo/=' $conf`
#	sed -i ''"$osrepolineno"'d' $conf
#	sed -i ''"$osrepolineno"' ihow_to_setup_os_repo='"$osrepoval"'' $conf
	replacewithcommandargs "how_to_setup_os_repo" $osrepoval $islast
fi
if [ "$firewallselinuxsettingflag" -eq 0 ]; then
#	firewallselinuxsettinglineno=`sed -n -e '/firewall_selinux_setting/=' $conf`
#	sed -i ''"$firewallselinuxsettinglineno"' ifirewall_selinux_setting='"$firewallselinuxsettingval"'' $conf
#	sed -i '$d' $conf 
	
	islast=0
        replacewithcommandargs "firewall_selinux_setting" $firewallselinuxsettingval $islast
fi
#cat $path/ui-installer/conf
$path/ui-installer/install
