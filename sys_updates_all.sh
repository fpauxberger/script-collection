#!/bin/bash

# This script updates deb, flatpak & snap packages in one go.
#
# Improvements welcome!
#
#
# paux 20250511
#
#
echo "**********************************************"
echo "**********************************************"
echo "  >>>>> Check all package systems for updates "
echo "**********************************************"
echo "**********************************************"


# flatpak updates
echo
echo "Let's see if there are updates for flatpak:"
sudo flatpak update
echo "********************************************"
echo 

# snap updates
echo "Checking snap for upates:"
sudo snap refresh
echo "********************************************"
echo 

# packages updates
echo 
echo "And finally refresh system repos and check for updates:"
echo "Checked for Fedora and Ubuntu distros"
echo 
echo 

mydistro=$(grep ^NAME /etc/*release | cut -d '=' -f2 | sed 's/"//g' | awk '{ print $1 }')
echo "Looks like you are running $mydistro!"
echo 

case $mydistro in
  Ubuntu) 
    sudo apt update && sudo apt upgrade
    if [ -f /var/run/reboot-required ]; then
      echo
      echo '   ----> Your system needs to be rebooted!'
      echo
    else
      echo
      echo 'No system changes done that require a reboot!'
      echo
    fi
    ;;
  Fedora) 
    sudo dnf upgrade --refresh
    sudo needs-restarting -r
    ;;
  *)
    echo "Your distro currently is not supported!"
    ;;
esac

echo "********************************************"
echo 
echo 
echo "********************************************"
echo "********************************************"
echo "  >>>>> All done"
echo "********************************************"
echo "********************************************"

exit 0
