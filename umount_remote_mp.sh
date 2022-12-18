#!/bin/bash


mapfile -t remote_mp < <( mount | grep // | awk '{print $3}' )
declare -p remote_mp

for i in "${remote_mp[@]}"; do sudo umount "${i}"; done

exit 0
