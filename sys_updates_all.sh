#!/bin/bash

# This script updates deb, flatpak & snap packages in one go.
#
# Improvements welcome!
#
#
# paux 20250511
#
#
echo "************************************************"
echo "************************************************"
echo "  >>> Check all package systems for updates <<< "
echo "************************************************"
echo "************************************************"
echo
echo

# flatpak updates
echo
echo "------------------------------------------------"
echo "FLATPAK update check"
echo "------------------------------------------------"

if command -v flatpak > /dev/null 2>&1; then
  flatpak update
else
  echo
  echo "++++++++++++++++++++++++++++++++++++++++++++++++"
  echo "!!! flatpak is not used on this system !!!      "
  echo "++++++++++++++++++++++++++++++++++++++++++++++++"
  echo
fi

# snap updates
echo
echo "------------------------------------------------"
echo "SNAP update check"
echo "------------------------------------------------"

if command -v snap > /dev/null 2>&1; then
  sudo snap refresh
else
  echo
  echo "++++++++++++++++++++++++++++++++++++++++++++++++"
  echo "!!! snap is not used on this system !!!         "
  echo "++++++++++++++++++++++++++++++++++++++++++++++++"
  echo
fi

# packages updates
echo
echo "------------------------------------------------"
echo "System repo update check                        "
echo "------------------------------------------------"

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
    echo
    sudo needs-restarting -r
    echo
    ;;
  *)
    echo
    echo "Your distro currently is not supported!"
    echo
    ;;
esac
echo 
echo 
echo "************************************************"
echo "************************************************"
echo "            >>> All done <<<                    "
echo "************************************************"
echo "************************************************"

exit 0
