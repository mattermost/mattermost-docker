FROM alpine:3.3

RUN apk add --update curl netcat-openbsd ca-certificates && rm -rf /var/cache/apk/*
RUN mkdir -p /mattermost/data

ENV MM_VERSION=3.8.1

RUN curl https://releases.mattermost.com/$MM_VERSION/mattermost-team-$MM_VERSION-linux-amd64.tar.gz | tar -xvz

RUN rm /mattermost/config/config.json
COPY config.template.json /

COPY docker-entry.sh /
RUN chmod +x /docker-entry.sh
ENTRYPOINT ["/docker-entry.sh"]

EXPOSE 80

VOLUME /mattermost/data

WORKDIR /mattermost/bin
CMD ["platform"]
