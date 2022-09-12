#!/bin/bash

echo

# Specify the name of your camera you want to use
# Run something like `lsusb | grep Webcam`
echo "What's my cameras name?"
mycam="C930e"
echo "  >> mycam: $mycam"

echo "Find the right video device."
sleep 1
devname=`ls -l /dev/v4l/by-id/ | grep $mycam | head -1`
devname=`echo ${devname:(-6)}`
echo "  >> Device: $devname"

sleep 2

echo "Set zoom for face-2-face meeting using green screen"
echo "  >> Running command: v4l2-ctl -d /dev/${devname} --set-ctrl=zoom_absolute=130"
v4l2-ctl -d /dev/${devname} --set-ctrl=zoom_absolute=130
sleep 1

echo

exit 0

