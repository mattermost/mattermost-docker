FROM postgres:9.4

# Install some packages to use WAL
RUN apt-get update \
    && apt-get install -y \
      build-essential \
      curl \
      daemontools \
      libffi-dev \
      libssl-dev \
      lzop \
      pv \
      python-dev \
    && curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | python \
    && pip install 'wal-e<1.0.0' \
    && apt-get remove -y \
      build-essential \
      python-dev \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin /tmp/* /var/tmp/*

# Add wale script
COPY setup-wale.sh /docker-entrypoint-initdb.d/

# Add and configure entrypoint and command
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["postgres"]
