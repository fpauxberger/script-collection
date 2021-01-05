#!/bin/bash

# This script tries to rebuild the v4l2loopback module
# based on the current version of the installed kernel.
#
# Improvements welcome!
#
#
# paux 20210105

#
# settings
#

# get v4l2loopback directory
echo "  INFO: I assume the v4l2loopback directory is somewhere in the HOME dir of the current user. So I will look there on any local fs mount points.."
for DIR in `find $HOME -mount -name v4l2loopback -type d`
  do 
    if test -d $DIR
      then V4LOOPDIR=$DIR
      else
        echo "! ERROR: Cannot find v4l2loopback directory, please fix that!"	      
        echo
	exit 0
    fi
done

# get current module version
if test -e $V4LOOPDIR/dkms.conf
  then 
    V4CONF=$V4LOOPDIR/dkms.conf
  else
    echo "! ERROR: Cannot find $V4CONF! Unable to determine module version, please fix that!"	  
    echo
    exit 0
fi
MODULEVERSION=`grep -i PACKAGE_VERSION $V4CONF | sed 's/[^0-9||.]*//g'`
echo "  INFO: Found v4l2loopback module version >$MODULEVERSION<. Will work with that."
KERNEL=`uname -r`
echo "  INFO: Found kernel version >$KERNEL<. Will work with that."


#
# Rebuild kernel module if required
#

MOD_KERNEL=`dkms status | awk {'print $3'} | sed 's/,$//'` 
if [ $KERNEL == $MOD_KERNEL ]
  then
    echo
    echo "  INFO: Status of the kernel modules loaded:"
    dkms_status=`dkms status`; echo "$dkms_status" | sed ':lbl; /^ \{'2'\}/! {s/^/ /;b lbl}'
    echo
    echo "  INFO: Module is built and loaded for the currently running kernel '$KERNEL'. Nothing to be done!"
    echo
  else
    echo "  INFO: Starting to build the module $MODULEVERSION for kernel $KERNEL:"
    sudo dkms build -k $KERNEL v4l2loopback/$MODULEVERSION && sudo dkms install -k $KERNEL v4l2loopback/$MODULEVERSION
    echo
    echo "  INFO: Status of the kernel modules loaded:"
    dkms_status=`dkms status`; echo "$dkms_status" | sed ':lbl; /^ \{'2'\}/! {s/^/ /;b lbl}'
    echo
fi

sleep 1

echo
echo "  INFO: If you see any old modules here, try removing them using 'sudo dkms remove -m v4l2loopback -v <module version> -k <kernel_version>."
echo "        In case you would like to run a fresh dkms build, remove all versions by running 'sudo dkms remove -m v4l2loopback/<module version> --all'"
echo "        and then re-run this script."
echo

echo "funny output"

exit 0
