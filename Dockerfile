FROM alpine

ENV BORG_VERSION=1.1.16

RUN set -x \
    && mkdir -p /opt/borgs/sbin \
    && mkdir -p /opt/borgs/bin \
    && apk update \
    && apk add py3-pip \
    && apk add openssl-dev \
    && apk add build-base \
    && apk add python3-dev \
    && apk add acl-dev \
    && apk add linux-headers \
    && apk add openssh-server \
    && apk add bash \
    && pip3 install borgbackup==$BORG_VERSION \
    && apk del build-base


    # && apt-get remove -y --purge build-essential libssl-dev liblz4-dev libacl1-dev \
    # && apt-get autoremove -y --purge \
    # && mkdir /var/run/sshd \
    # && mkdir /var/backups/borg \
    # && rm -rf /var/lib/apt/lists/*


RUN set -x \
    && sed -i \
        -e 's/^#PasswordAuthentication yes$/PasswordAuthentication no/g' \
        -e 's/^#PermitRootLogin without-password$/PermitRootLogin no/g' \
        -e 's/^X11Forwarding yes$/X11Forwarding no/g' \
        -e 's/^#LogLevel .*$/LogLevel ERROR/g' \
        -e 's/^#PubkeyAuthentication.*$/PubkeyAuthentication yes/g' \
        -e 's/^AuthorizedKeysFile.*$/AuthorizedKeysFile \/opt\/borgs\/etc\/users\/%u/g' \
        /etc/ssh/sshd_config

VOLUME [ "/backups", "/opt/borgs/etc" ]

ADD ./entrypoint.sh /
ADD ./createuser.sh /opt/borgs/sbin/createuser
ADD ./profile /opt/borgs/rbash_profile
RUN chmod a+x /opt/borgs/sbin/createuser
RUN ln -sf /opt/borgs/sbin/createuser /usr/sbin

# why doesnt bash in alpine already have this?
RUN cp /bin/bash /bin/rbash
RUN ln -sf /usr/bin/borg /opt/borgs/bin
RUN mkdir -p /opt/borgs/etc/ssh/



EXPOSE 22
CMD ["/entrypoint.sh"]
