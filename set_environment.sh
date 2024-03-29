#!/bin/bash

#
# Script to check the current LAN settings and
# mounts my nas server(s) accordingly
#
# TODO:
# - VLAN to home
# 
# Possible options:
#   -v	Sets the output to verbose
#   -d	Script runs in debug mode only
#

verbose=0
debug=0

while getopts "v d" OPTION
do
  case $OPTION in
    v) verbose=1
       ;;
    d) debug=1
       ;;
  esac
done


# Read yml config file
# A big thanks to Piotr Kuczynski: https://gist.github.com/pkuczynski/8665367
. parse_yaml.sh

# read local config file
eval $(parse_yaml conf/environment.yml "config_")


#
# Define some basic functions
#

# Verbose output
function verbose () {
  if [[ $verbose -eq 1 ]]; then
    echo "$@"
  fi
}

# Debug run
function debug () {
  if [[ $debug -eq 1 ]]; then
    echo "$@"
  fi
}



verbose ""
verbose "********************************"
verbose "****** Full config file ********"
verbose "********************************"
verbose ""
verbose "config home (W)LAN1"
verbose "  SSID: $config_home_ssid"
verbose "config nas"
verbose "  Production: NAS server name: $config_nas_nasserver_prod"
verbose "  Production: NAS path to home: $config_nas_homedrive_prod"
verbose "  Production: NAS path to family share: $config_nas_familyshare_prod"
verbose "  Production: NAS path to third share: $config_nas_autohome_prod"
verbose "  Production: Local mountpoint home: $config_nas_home_mountpoint_prod"
verbose "  Production: Local mountpoint family: $config_nas_family_mountpoint_prod"
verbose "  Production: Local third mountpoint: $config_nas_family_third_mountpoint_prod"
verbose "  Production: NAS user: $config_nas_user_prod"
verbose "  Production: password: $config_nas_password_prod"
verbose "  Backup: NAS server name: $config_nas_nasserver_bak"
verbose "  Backup: NAS path to home: $config_nas_homedrive_bak"
verbose "  Backup: Local mountpoint: $config_nas_mountpoint_bak"
verbose "  Backup: NAS user: $config_nas_user_bak"
verbose "  Backup: password: $config_nas_password_bak"
verbose "config local"
verbose "  Local UID: $config_luser_luid"
verbose "  Local GID: $config_luser_lgid"
verbose "config vpn"
verbose "  VPN connection: $config_vpn_vconnection"
verbose ""
verbose "********************************"
verbose ""

# Find network devices
connection=$(nmcli device status | grep -e 'wifi.* connected' -e 'ethernet.* connected')
if [ -z "$connection" ]
  then 
    echo "There seems to be no network connection! Exiting..."
    exit 1
  else
    echo ""
    echo "Found at least one an active network connection!"
    echo "$connection"
    echo ""
    if [ -z $ssid ] # prefer LAN over Wifi
      then 
        lanid=$(nmcli device status | grep 'ethernet.* connected' | awk '{ print $1 }')
        myip=`ip route get 8.8.4.4 | head -1 | awk '{print $7}'`
        echo "We are connected to a LAN on interface $lanid! My IP is $myip."    
        network=lan
      else 
        wificard=$(nmcli device status | grep 'wifi.* connected' | awk '{ print $1 }')
        ssid=$(nmcli device status | grep 'wifi.* connected' | awk '{ print $4 }')
        myip=`ip route get 8.8.4.4 | head -1 | awk '{print $7}'`
        echo "Connected to $ssid on interface $wificard! My IP is $myip."
        network=wlan
    fi
fi 

verbose ""
verbose "network connection: >$network<."
verbose "My IP: >$myip=<"
verbose ""

# Check if we sit at HOME
check_home=$(ping -c1 $config_nas_nasserver_prod &>/dev/null)
if [ $? -eq 0 ]
  then 
    home=true
  else
    home=false
fi

#
# If @home mount NAS. If not start vpn tunnel first and then mount NAS
#

if [ "$home" == "true" ]
  then
    verbose ""
    verbose "--> Seems you are at home!"
    verbose ""

    if [[ $debug -eq 1 ]]
      then 
        verbose "sudo mount -t cifs -o user=$config_nas_user,password=$config_nas_password,uid=$config_luser_luid,gid=$config_luser_lgid,nounix,vers=2.0 $config_nas_homedrive $config_nas_mountpoint"
        exit 0
      else 
        verbose "Mounting drive(s) from $config_nas_nasserver_prod:"
	verbose "  user data: sudo mount -t cifs -o user=$config_nas_user_prod,password=$config_nas_password_prod,uid=$config_luser_luid,gid=$config_luser_lgid,nounix,vers=2.0 $config_nas_homedrive_prod $config_nas_home_mountpoint_prod"
        sudo mount -t cifs -o user=$config_nas_user_prod,password=$config_nas_password_prod,uid=$config_luser_luid,gid=$config_luser_lgid,nounix,vers=2.0 $config_nas_homedrive_prod $config_nas_home_mountpoint_prod
	verbose "  family share: sudo mount -t cifs -o user=$config_nas_user_prod,password=$config_nas_password_prod,uid=$config_luser_luid,gid=$config_luser_lgid,nounix,vers=2.0 $config_nas_familyshare_prod $config_nas_family_mountpoint_prod"
        sudo mount -t cifs -o user=$config_nas_user_prod,password=$config_nas_password_prod,uid=$config_luser_luid,gid=$config_luser_lgid,nounix,vers=2.0 $config_nas_familyshare_prod $config_nas_family_mountpoint_prod
	verbose "  user home: sudo mount -t cifs -o user=$config_nas_user_prod,password=$config_nas_password_prod,uid=$config_luser_luid,gid=$config_luser_lgid,nounix,vers=2.0 $config_nas_autohome_prod $config_nas_home_third_mountpoint_prod"
        sudo mount -t cifs -o user=$config_nas_user_prod,password=$config_nas_password_prod,uid=$config_luser_luid,gid=$config_luser_lgid,nounix,vers=2.0 $config_nas_autohome_prod $config_nas_third_mountpoint_prod
        if [ $? -eq 0 ]
          then
            list=`mount | grep nas`
            verbose ""
            verbose "The following remote mountpoints exist:"
            verbose "$list"
            verbose ""
            exit 0
          else
            verbose "Unable to mount home drive! Exiting..."
            exit 1
        fi
    fi
  else
    echo ""
    echo  "--> Looks like you are not at home. This requires some more effort to mount your homedrive. Let's get it done..."
    echo ""

### TODO
### BACKUP SERVER
### VPN connection for external mount

    ### active_con=$(nmcli con | grep "$active_card")
    ### activ_vpn=$(nmcli con | grep "$ssid")

    ### if [ "${activ_con}" -a ! "${activ_vpn}" ];
    ###if [ "${ssid}" -a ! "${$config_home_ssid}" ];
    ###  then
    ###    if [[ $debug -eq 1 ]]
    ###      then
    ###        verbose "nmcli con up id '${config_vpn_vconnection}'"
    ###        exit 0
    ###      else
    ###        nmcli con up id "${config_vpn_vconnection}"
    ###    fi
    ###fi
    # Check if tunnel is active
    ### if [ $? -eq 0 ]
###       then
    ###     verbose ""
###         verbose "Tunnel successfully activated! Mountin NAS..."
        ### verbose ""

        ### sleep 1

        ### verbose ""
        ### verbose "Finding the IP of my $config_nas_nasserver back at home..."
        ### verbose ""
        #
        # Quick and dirty hack to get the NAS mounted in a tunneled area - needs some more brain and time to make it nice
        #
 ###       ipofnas=`nmap -T5 -sP $config_home_network | grep -i $config_nas_shortname | head -1 | awk {'print $6'}`
 ###       ipofnas=`echo "${ipofnas:1:${#string}-1}"`

 ###       verbose ""
 ###       verbose "My NAS at home has got IP address: >$ipofnas<!"
 ###       verbose ""


 ###       sleep 2

###        if [[ $debug -eq 1 ]]
###          then 
            ### verbose "sudo mount -t cifs -o user=$config_nas_user,password=$config_nas_password,uid=$config_luser_luid,gid=$config_luser_lgid,nounix,vers=2.0 $config_nas_homedrive $config_nas_mountpoint"
###            verbose "sudo mount -t cifs -o user=$config_nas_user,password=$config_nas_password,uid=$config_luser_luid,gid=$config_luser_lgid,nounix,vers=2.0 //$ipofnas/home $config_nas_mountpoint"
###            exit 0
###          else
###            sudo mount -t cifs -o user=$config_nas_user,password=$config_nas_password,uid=$config_luser_luid,gid=$config_luser_lgid,nounix,vers=2.0 //$ipofnas/home $config_nas_mountpoint
###           if [ $? -eq 0 ]
###              then
###                verbose "Done!"
###                exit 0
###              else
###                verbose "Unable to mount home drive! Exiting..."
###                exit 1
###            fi
###            verbose ""
	    ###verbose "Tunnel could not be started. Please check that! Exiting..."
 ###           verbose ""
 ###           exit 1
   ###    fi
###    fi
fi

exit 0
