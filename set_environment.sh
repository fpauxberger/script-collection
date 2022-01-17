#!/bin/bash

#
# Script to check the current LAN settings and
# set the environment accordingly.
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
verbose "  $config_home_ssid"
verbose "  $config_home_network"
verbose "config nas"
verbose "  $config_nas_shortname"
verbose "  $config_nas_homedrive"
verbose "  $config_nas_mountpoint"
verbose "  $config_nas_user"
verbose "  $config_nas_password"
verbose "config local"
verbose "  $config_luser_luid"
verbose "  $config_luser_lgid"
verbose "config vpn"
verbose "  $config_vpn_vconnection"
verbose ""
verbose "********************************"
verbose ""

# Find network devices

wificard=$(sudo lshw -class network -short | grep Wi-Fi | awk  '{ print $2 }')
  ssid=$(nmcli device status | grep 'wifi.* connected' | awk '{ print $4 }')
ethernetcard=$(sudo lshw -class network -short | grep Ethernet | awk  '{ print $2 }')
  lanid=$(nmcli device status | grep 'ethernet.* connected' | awk '{ print $4 }')

verbose ""
verbose "*** Network configuration dump ***"
verbose ""
verbose "Wireless card: >$wificard<"
verbose "SSID: >$ssid<"
verbose "Ethernet card: >ethernetcard=<"
verbose "LANID: >$lanid<"


# See if we are connected via wifi or LAN

if [ -z $ssid ] 
  then
    verbose "--> We are not connected to a Wifi!"
    network=lan
  else
    verbose ""
    verbose "Connected to $ssid on interface: $active_card and my IP is $myip."
    verbose ""
    network=wlan
fi
myip=`ip route get 8.8.4.4 | head -1 | awk '{print $7}'`

debug ""
debug "echo $network"
debug "echo $myip"

exit 1

####################
#######################
#####################
########################
####################
#################


#
# If @home mount NAS. If not start vpn tunnel first and then mount NAS
#

if [ "$network == wlan" ] && [ "$ssid" == "$config_home_ssid" ]
  then
    verbose ""
    verbose "--> Seems you are at home!"
    verbose ""

    if [[ $debug -eq 1 ]]
      then 
        verbose "sudo mount -t cifs -o user=$config_nas_user,password=$config_nas_password,uid=$config_luser_luid,gid=$config_luser_lgid,nounix,vers=2.0 $config_nas_homedrive $config_nas_mountpoint"
        exit 0
      else 
	verbose "sudo mount -t cifs -o user=$config_nas_user,password=$config_nas_password,uid=$config_luser_luid,gid=$config_luser_lgid,nounix,vers=2.0 $config_nas_homedrive $config_nas_mountpoint"
        sudo mount -t cifs -o user=$config_nas_user,password=$config_nas_password,uid=$config_luser_luid,gid=$config_luser_lgid,nounix,vers=2.0 $config_nas_homedrive $config_nas_mountpoint
        if [ $? -eq 0 ]
          then
            list=`ls -al $config_nas_mountpoint`
            verbose "$list"
            exit 0
          else
            verbose "Unable to mount home drive! Exiting..."
            exit 1
        fi
    fi
  else
    verbose ""
    verbose "You are connected to >$ssid<. This requires some more effort to mount your homedrive. Let's get it done..."
    verbose ""

    ### active_con=$(nmcli con | grep "$active_card")
    ### activ_vpn=$(nmcli con | grep "$ssid")

    ### if [ "${activ_con}" -a ! "${activ_vpn}" ];
    if [ "${ssid}" -a ! "${$config_home_ssid}" ];
      then
        if [[ $debug -eq 1 ]]
          then
            verbose "nmcli con up id '${config_vpn_vconnection}'"
            exit 0
          else
            nmcli con up id "${config_vpn_vconnection}"
        fi
    fi
    # Check if tunnel is active
    if [ $? -eq 0 ]
      then
        verbose ""
        verbose "Tunnel successfully activated! Mountin NAS..."
        verbose ""

        sleep 1

        verbose ""
        verbose "Finding the IP of my NAS back in Schluckenau..."
        verbose ""
        #
        # Quick and dirty hack to get the NAS mounted in a tunneled area - needs some more brain and time to make it nice
        #
        ipofnas=`nmap -T5 -sP $config_home_network | grep -i $config_nas_shortname | head -1 | awk {'print $6'}`
        ipofnas=`echo "${ipofnas:1:${#string}-1}"`

        verbose ""
        verbose "My NAS in Schluckenau has got IP address: >$ipofnas<!"
        verbose ""


        sleep 2

        if [[ $debug -eq 1 ]]
          then 
            ### verbose "sudo mount -t cifs -o user=$config_nas_user,password=$config_nas_password,uid=$config_luser_luid,gid=$config_luser_lgid,nounix,vers=2.0 $config_nas_homedrive $config_nas_mountpoint"
            verbose "sudo mount -t cifs -o user=$config_nas_user,password=$config_nas_password,uid=$config_luser_luid,gid=$config_luser_lgid,nounix,vers=2.0 //$ipofnas/home $config_nas_mountpoint"
            exit 0
          else
            sudo mount -t cifs -o user=$config_nas_user,password=$config_nas_password,uid=$config_luser_luid,gid=$config_luser_lgid,nounix,vers=2.0 //$ipofnas/home $config_nas_mountpoint
            if [ $? -eq 0 ]
              then
                verbose "Done!"
                exit 0
              else
                verbose "Unable to mount home drive! Exiting..."
                exit 1
            fi
            verbose ""
	    verbose "Tunnel could not be started. Please check that! Exiting..."
            verbose ""
            exit 1
        fi
    fi
fi

exit 0
