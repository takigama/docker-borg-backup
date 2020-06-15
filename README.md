# docker-borg-backup-secure

Building on ginkels container, this is an attempt at making a docker container with added security for the borg backup software.

For more information about Borg Backup, an excellent deduplicating backup, refer to: https://www.borgbackup.org/

The idea behind this container is to stop users from being able to modify backups except using the borg command, to achieve this the following occurs:

* all users get a rbash shell with borg being their only command
* all users run with a seperate UID - for my purposes, each server/workstation that backs up to this machine would be a seperate user


## Usage

```
docker run --name borg -v <borg_backup_volume>:/backups -v <borg_user_list>:/opt/borgs/etc/users ...
```

To then create a user, run the following:

```
docker exec -it borg createuser <username> "<ssh key>"
```

To delete a user - um... i'll get to that soon(tm), but currently this involes:

```
docker exec borg deluser <username>
docker exec borg rm -rf /backups/<username>       # if you wish to delete their data
docker exec borg rm -f /opt/borgs/etc/users/<username>       # if you wish to delete their key
```

## Layout

The container users two volumes, /backups and /etc/borgs/etc/users. If you want persistent data, you'll need both

 * /etc/borgs/etc/users/$username - each is a pubkey for $username, ultimately its our list of active users
 * /backups/$username - permission 0710 (user cant write in their own home directory or even see the files that exist there. Home directory is owned by root)
 * /backups/$username/repo - loocation for actual backups (user writable/readable, should be the only location the user can actually see anything)


## License

The files contained in this Git repository are licensed under the following license. This license explicitly does not cover the Borg Backup and Debian software packaged when running the Docker build. For these componensts, separate licenses apply that you can find at:

* https://borgbackup.readthedocs.io/en/stable/authors.html#license
* https://www.debian.org/legal/licenses/

Copyright 2018 TG Byte Software GmbH

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
