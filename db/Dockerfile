FROM postgres:9.4-alpine

RUN apk update \
    && apk add --no-cache python python-dev ca-certificates gcc linux-headers musl-dev \
       libffi libffi-dev openssl openssl-dev bash \
    && apk add py-pip \
    && pip install --upgrade pip \
    && pip install 'wal-e<1.0.0' \
    && apk del python-dev gcc linux-headers musl-dev libffi-dev openssl-dev

COPY setup-wale.sh /docker-entrypoint-initdb.d/
COPY docker-entrypoint1.sh /
RUN chmod +x /docker-entrypoint1.sh

ENTRYPOINT ["/docker-entrypoint1.sh"]

CMD ["postgres"]
