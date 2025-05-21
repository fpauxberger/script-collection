#!/bin/bash
if [ -f /var/run/reboot-required ]; then
  echo
  echo '   ----> Your system needs to be rebooted!'
  echo
else
  echo
  echo 'No system changes done that require a reboot!'
  echo
fi
exit 0
