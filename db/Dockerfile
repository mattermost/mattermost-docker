FROM postgres:9.4-alpine

ENV DEFAULT_TIMEZONE UTC

# Install some packages to use WAL
RUN apk add --no-cache \
      build-base \
      curl \
      libc6-compat \
      libffi-dev \
      linux-headers \
      python-dev \
      py-cryptography \
    && curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | python \
    && pip --no-cache-dir install 'wal-e<1.0.0' envdir \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# Add wale script
COPY setup-wale.sh /docker-entrypoint-initdb.d/

# Add and configure entrypoint and command
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["postgres"]
