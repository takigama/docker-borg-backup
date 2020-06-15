FROM debian:9

ENV BORG_VERSION=1.1.13

RUN set -x \
    && mkdir -p /opt/borgs/sbin \
    && mkdir -p /opt/borgs/bin \
    && apt-get update \
    && apt-get install -y curl \
    && sed -i "s/httpredir.debian.org/`curl -s -D - http://httpredir.debian.org/demo/debian/ | awk '/^Link:/ { print $2 }' | sed -e 's@<http://\(.*\)/debian/>;@\1@g'`/" /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y openssh-server python3-pip build-essential libssl-dev libssl1.0.2 liblz4-dev liblz4-1 libacl1-dev libacl1 \
    && rm -f /etc/ssh/ssh_host_* \
    && pip3 install borgbackup==$BORG_VERSION \
    && apt-get remove -y --purge build-essential libssl-dev liblz4-dev libacl1-dev \
    && apt-get autoremove -y --purge \
    && mkdir /var/run/sshd \
    && mkdir /var/backups/borg \
    && rm -rf /var/lib/apt/lists/*

RUN set -x \
    && sed -i \
        -e 's/^#PasswordAuthentication yes$/PasswordAuthentication no/g' \
        -e 's/^PermitRootLogin without-password$/PermitRootLogin no/g' \
        -e 's/^X11Forwarding yes$/X11Forwarding no/g' \
        -e 's/^#LogLevel .*$/LogLevel ERROR/g' \
        -e 's/^#AuthorizedKeysFile.*$/AuthorizedKeysFile \/opt\/borgs\/etc\/users\/%u/g' \
        /etc/ssh/sshd_config

VOLUME [ "/backups", "/opt/borgs/etc/users" ]

ADD ./entrypoint.sh /
ADD ./createuser.sh /opt/borgs/sbin/createuser
ADD ./profile /opt/borgs/etc/rbash_profile
RUN chmod a+x /opt/borgs/sbin/createuser
RUN ln -sf /opt/borgs/sbin/createuser /usr/sbin
RUN ln -sf /usr/local/bin/borg /opt/borgs/bin


EXPOSE 22
CMD ["/entrypoint.sh"]
