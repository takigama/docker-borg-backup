#!/bin/bash

# this script will get prettier, I promise

function usage {
    echo "Usage: $0 username ssh-key"
}

# clean our username
function clean {
    STRING=$1
    CLEAN="${STRING//_/}" && \
    CLEAN="${CLEAN// /_}" && \
    CLEAN="${CLEAN//[^a-zA-Z0-9]/}" && \
    CLEAN="${CLEAN,,}"
    echo $CLEAN
}

if [ "x$1" == "x" ]
then
    usage
    exit
fi

# docker not updating my create user script.. pos

username=$(clean $1)

if [ ${#username} -gt 12 ]
then
    echo "Username cant be greater than 12 characters"
    exit 1
fi


adduser  --disabled-password --no-create-home --gecos "Borg Backup $username" --quiet $username --shell /bin/rbash --home /backups/$username/ > /dev/null 2>&1
if [ $? == 0 ]
then
    mkdir -p /backups/$username/repo/
else 
    echo User exists, $username, enforcing settings
fi

echo $2 > /opt/borgs/etc/users/$username
chown root:$username /opt/borgs/etc/users/$username
chmod 640 /opt/borgs/etc/users/$username

chown -R root:$username /backups/$username
chmod 710 /backups/$username
cp -f /opt/borgs/etc/rbash_profile /backups/$username/.bash_profile
chown root:root /backups/$username/.bash_profile
chmod 644 /backups/$username/.bash_profile
chown $username:$username /backups/$username/repo/

echo User $username created, backup path is /backups/$username/repo/



