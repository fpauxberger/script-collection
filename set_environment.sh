#!/bin/bash

#
# Script to check the current LAN settings and
# set the environment accordingly.
# 
# Possible options:
#   -v	Sets the output to verbose
#   -d	Script runs in debug mode
#

verbose=0
debug=0

while getopts "v" OPTION
do
  case $OPTION in
    v) verbose=1
       ;;
    d) debug=1
       ;;
  esac
done


#
# Define some basic functions
#

# Verbose output
function verbose () {
    if [[ $verbose -eq 1 ]]; then
        echo "$@"
    fi
}

# Debug run only
function debug () {
    if [[ $debug -eq 1 ]]; then
        echo "$@"
    fi
}

### ARGV0=$0 # First argument is shell command (as in C)
### verbose "Command: $ARGV0"
### 
### ARGC=$#  # Number of args, not counting $0
### verbose "Number of args: $ARGC"
### 
### i=1  # Used as argument index
### while true; do
### 	if [ $1 ]; then
### 		echo "Argv[$i] = $1" # Always print $1, shifting $2 into $1 later
### 		shift
### 	else
### 		break # Stop loop when no more args.
### 	fi
### 	i=$((i+1))
### done
### verbose "Done."


#
# Find active wifi card and SSID
#
active_card=`ip link sho | grep w | awk '{print substr($2, 1, length($2)-1)}'`
ssid=`nmcli | grep $active_card | awk '{print $4}'`

verbose "Connected to $ssid on interface: $active_card."


# If in LAN @home mount NAS. If not start vpn tunnel first
# and then mount NAS

case $ssid in 

  "FCP-Network" )

  verbose "Seems you are in Schluckenau..."
  # Mount nas
  sudo mount -t cifs --verbose -o user=paux,uid=1000,gid=1000,nounix,vers=2.0 //nasdcb0ba/home /home/paux/nas/homedrive
  
  if [ $? -eq 0 ]
    then
      exit 0
  else
    exit 1
  fi
  ;;

/*

REQUIRED_CONNECTION_NAME="<name-of-connection>"
VPN_CONNECTION_NAME="<name-of-vpn-connection>"


activ_con=$(nmcli con status | grep "${REQUIRED_CONNECTION_NAME}")
activ_vpn=$(nmcli con status | grep "${VPN_CONNECTION_NAME}")
if [ "${activ_con}" -a ! "${activ_vpn}" ];
then
    nmcli con up id "${VPN_CONNECTION_NAME}"
fi

*/











  "MyHomeIsMyCastle" )

  verbose "Looks like you are at Maeusberg"

  # Start VPN
  VPN_CONNECTION_NAME="Schluckenau"
  activ_vpn=$(nmcli con | grep "${VPN_CONNECTION_NAME}")
  if [ "${activ_con}" -a ! "${activ_vpn}" ];
    then
      nmcli con up id "${VPN_CONNECTION_NAME}"
  fi

  # Mount nas
  sudo mount -t cifs --verbose -o user=paux,uid=1000,gid=1000,nounix,vers=2.0 //NASDCB0BA/home /home/paux/nas/homedrive
  ;;

esac

exit 0
