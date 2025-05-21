#!/bin/bash
if [ -f /var/run/reboot-required ]; then
  echo
  echo '   ----> Your system needs to be rebooted!'
  echo
fi

