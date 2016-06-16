FROM alpine:3.3

RUN apk add --update curl netcat-openbsd ca-certificates && rm -rf /var/cache/apk/*
RUN mkdir -p /mattermost/data

RUN curl https://releases.mattermost.com/3.0.2/mattermost-team-3.0.2-linux-amd64.tar.gz | tar -xvz

RUN rm /mattermost/config/config.json
COPY config.template.json /

COPY docker-entry.sh /
RUN chmod +x /docker-entry.sh
ENTRYPOINT ["/docker-entry.sh"]

EXPOSE 80
