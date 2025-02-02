FROM alpine

ENV BORG_VERSION=1.4.0

RUN set -x \
    && mkdir -p /opt/borgs/sbin \
    && mkdir -p /opt/borgs/bin \
    && apk update \
    && apk add py3-pip \
    && apk add openssl-dev \
    && apk add build-base \
    && apk add linux-headers \
    && apk add python3-dev \
    && apk add acl-dev \
    && apk add openssh-server \
    && apk add bash \
    && apk add py3-lz4 py3-lz4-pyc \
    && apk add lz4 lz4-dev \
    && apk add zstd-dev zstd-libs \
    && apk add libxxhash xxhash-dev \
    && pip3 install --break-system-packages borgbackup==$BORG_VERSION \
    && apk del build-base linux-headers python3-dev lz4-dev xxhash-dev

    # && apk del build-base linux-headers python3-dev acl-dev lz4-dev xxhash-dev


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
ADD ./benchmarktest.sh /benchmarktest.sh
ADD ./profile /opt/borgs/rbash_profile
RUN chmod a+x /opt/borgs/sbin/createuser
RUN ln -sf /opt/borgs/sbin/createuser /usr/sbin

# why doesnt bash in alpine already have this?
RUN cp /bin/bash /bin/rbash
RUN ln -sf /usr/bin/borg /opt/borgs/bin
RUN mkdir -p /opt/borgs/etc/ssh/

# lastly clean out the apk caches
RUN apk cache clean
RUN apk cache purge



EXPOSE 22
CMD ["/entrypoint.sh"]
