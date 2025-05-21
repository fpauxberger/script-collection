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
echo "Let's see if there are updates for flatpak:"
sudo flatpak update
echo "********************************************"
echo 

# snap updates
echo "Checking snap for upates:"
sudo snap refresh
echo "********************************************"
echo 

# deb packages updates
echo "And finally refresh the deb repos and check for updates:"
sudo apt update && sudo apt upgrade
echo "********************************************"
echo 
echo 


echo "********************************************"
echo "********************************************"
echo "  >>>>> All done"
echo "********************************************"
echo "********************************************"

exit 0
