#!/bin/bash

dpkg-reconfigure openssh-server

mkdir -p /backups > /dev/null 2>&1
chmod 711 /backups

# check user list
echo "Start user check"
for i in /opt/borgs/etc/users/*
do
    thisuser=$(basename $i)
    if [ "x$thisuser" == "x*" ] 
    then
        echo "No users exist yet"
    else 
        echo "Checking user $thisuser"
        createuser $thisuser "`cat /opt/borgs/etc/users/$thisuser`"
    fi
done


exec /usr/sbin/sshd -D -e
