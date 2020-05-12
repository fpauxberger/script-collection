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
# Thank you to Piotr Kuczynski: https://gist.github.com/pkuczynski/8665367
. parse_yaml.sh

# read yaml file
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


verbose ""
verbose "********************************"
verbose "****** Full config file ********"
verbose "********************************"
verbose ""
verbose "config home (W)LAN1"
verbose "  $config_schluckenau_ssid"
verbose "config nas"
verbose "  $config_nas_homedrive"
verbose "  $config_nas_mountpoint"
verbose "  $config_nas_user"
verbose "config local"
verbose "  $config_luser_luid"
verbose "  $config_luser_lgid"
verbose "config vpn"
verbose "  $config_vpn_vconnection"
verbose ""
verbose "********************************"
verbose ""


#
# Find active wifi card and SSID
#
active_card=`ip link sho | grep w | awk '{print substr($2, 1, length($2)-1)}'`
ssid=`nmcli | grep $active_card | awk '{print $4}'`
myip=`ip route get 8.8.4.4 | head -1 | awk '{print $7}'`

verbose ""
verbose "Connected to $ssid on interface: $active_card and my IP is $myip."
verbose ""

#
# If @home mount NAS. If not start vpn tunnel first and then mount NAS
#

if [ $ssid == "$config_schluckenau_ssid" ]
  then
    verbose ""
    verbose "--> Seems you are in Schluckenau..."
    verbose ""

    if [[ $debug -eq 1 ]]
      then 
        verbose "sudo mount -t cifs --verbose -o user=$config_nas_user,uid=$config_luser_luid,gid=$config_luser_lgid,nounix,vers=2.0 $config_nas_homedrive $config_nas_mountpoint"
        exit 0
      else 
        sudo mount -t cifs --verbose -o user=$config_nas_user,uid=$config_luser_luid,gid=$config_luser_lgid,nounix,vers=2.0 $config_nas_homedrive $config_nas_mountpoint
        if [ $? -eq 0 ]
          then
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

    active_con=$(nmcli con | grep "$active_card")
    activ_vpn=$(nmcli con | grep "$ssid")
    if [ "${activ_con}" -a ! "${activ_vpn}" ];
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

        sleep 2
        if [[ $debug -eq 1 ]]
          then 
            verbose "sudo mount -t cifs --verbose -o user=$config_nas_user,uid=$config_luser_luid,gid=$config_luser_lgid,nounix,vers=2.0 $config_nas_homedrive $config_nas_mountpoint"
            exit 0
          else
            sudo mount -t cifs --verbose -o user=$config_nas_user,uid=$config_luser_luid,gid=$config_luser_lgid,nounix,vers=2.0 $config_nas_homedrive $config_nas_mountpoint
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
