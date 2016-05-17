FROM postgres:9.4

RUN apt-get update \
    && apt-get install -y python-dev lzop pv daemontools curl build-essential \
    && curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | python \
    && pip install wal-e \
    && apt-get remove -y build-essential python-dev \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD make_db.sh /docker-entrypoint-initdb.d/
ADD setup-wale.sh /docker-entrypoint-initdb.d/
COPY docker-entrypoint1.sh /
RUN chmod +x /docker-entrypoint1.sh

ENTRYPOINT ["/docker-entrypoint1.sh"]

CMD ["postgres"]
