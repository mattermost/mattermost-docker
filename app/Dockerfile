FROM alpine:3.5

RUN apk add --update curl netcat-openbsd ca-certificates && rm -rf /var/cache/apk/*
RUN mkdir -p /mattermost/data

RUN curl https://releases.mattermost.com/3.8.1/mattermost-team-3.8.1-linux-amd64.tar.gz | tar -xvz
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

RUN rm /mattermost/config/config.json
COPY config.template.json /

COPY docker-entry.sh /
RUN chmod +x /docker-entry.sh
ENTRYPOINT ["/docker-entry.sh"]

EXPOSE 80
