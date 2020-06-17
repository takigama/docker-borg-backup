# docker-borg-backup-secure

Building on ginkels container, this is an attempt at making a docker container with added security for the borg backup software.

For more information about Borg Backup, an excellent deduplicating backup, refer to: https://www.borgbackup.org/

The idea behind this container is to stop users from being able to modify backups except using the borg command, to achieve this the following occurs:

* all users get a rbash shell with borg being their only command
* all users run with a seperate UID - for my purposes, each server/workstation that backs up to this machine would be a seperate user

## Why?

Im very paranoid about push backups and those that occur over ssh withoutpasswords are scary. Often i'll be backup publicly hosted VM's and the idea they can just ssh back to an internal host really increased my fear factor. This is my attempt at making that as safe as
possible.

Ultimately, i've found borg to be quite good so i think its worth the effort.


## Usage

The best tag to pull currently is alpine-multiarch-latest. As its name suggests its based on alpine and it supports most common architectures (386, x86_64, arm, arm64, etc). This tag is updated manually rather then being built from an autobuild on docker hub as I cannot figure out how to make autobuilt work on docker hub with multiple architectures! Ultimately alpine will become master soon enough as I'll exit the debian based image.

```
docker run --name borg -v <borg_backup_volume>:/backups -v <borg_user_list_location>:/opt/borgs/etc takigama/secured-borg-server:alpine-multiarch-latest
```

To then create a user, run the following:

```
docker exec borg createuser <username> "<ssh key>", for example:

docker exec borg createuser john "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDSkT3A1j89RT/540ghIMHXIVwNlAEM3WtmqVG7YN/wYwtsJ8iCszg4/lXQsfLFxYmEVe8L9atgtMGCi5QdYPl4X/c+5YxFfm88Yjfx+2xEgUdOr864eaI22yaNMQ0AlyilmK+asewfaszxcvzxcvzxcv+MCUWo+cyBFZVGOzrjJGEcHewOCbVs+IJWBFSi6w1enbKGc+RY9KrnzeDKWWqzYnNofiHGVFAuMxrmZOasqlTIKiC2UK3RmLxZicWiQmPnpnjJRo7pL0oYM9r/sIWzD6i2S9szDy6aZ john@host"
```

To delete a user - um... i'll get to that soon(tm), but currently this involes:

```
docker exec borg deluser <username>
docker exec borg rm -rf /backups/<username>       # if you wish to delete their data
docker exec borg rm -f /opt/borgs/etc/users/<username>       # if you wish to delete their key
```

How I actually run this in my evironment:
```
docker network create -d macvlan --subnet=10.12.12.0/24 --gateway=10.12.12.1 -o parent=eth2 vlan_12
docker create --net vlan_12 --ip 10.12.12.222 --name="borgs" .... 
```

This creates a layer 2 interface directly between the host and the network, I then assign an IP direct to the container, that way theres no direct (simple) way of getting to host from container (or even from the network). In "vlan_12", theres just a firewall and the docker container   

## Layout

The container users two volumes, /backups and /etc/borgs/etc/. If you want persistent data, you'll need both

 * /etc/borgs/etc/users/$username - each is a pubkey for $username, ultimately its our list of active users
 * /backups/$username - permission 0710 (user cant write in their own home directory or even see the files that exist there. Home directory is owned by root)
 * /backups/$username/repo - loocation for actual backups (user writable/readable, should be the only location the user can actually see anything)

## TODO

 * Create a multi-arch version (this looks needlessly complex) that builds with docker hub
 * Tidy-Up the create user script (really need to make sure ssh key cant be the cause of annoying errors)
 * Small nodejs interface for managing environment/users (maybe)
 * Create a delete user script perhaps
 * Test on arm32/64
 * Test with alpine base


 ## Changes

  * 0.9 - Initial build
  * alpine:0.9 - the alpine based build (so far seems to work ok)

## Attributions

Base on the borg container by tgbye - https://github.com/tgbyte/docker-borg-backup


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
