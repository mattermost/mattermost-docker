FROM alpine:3.6

# Some ENV variables
ENV PATH="/mattermost/bin:${PATH}"
ENV MM_VERSION=4.6.1

# Build argument to set Mattermost edition
ARG edition=enterprise
ARG PUID=1000
ARG PGID=1000

# Install some needed packages
RUN apk add --no-cache \
    ca-certificates \
    curl \
    jq \
    libc6-compat \
    libffi-dev \
    linux-headers \
    mailcap \
    netcat-openbsd \
    xmlsec-dev \
    && rm -rf /tmp/*

# Get Mattermost
RUN mkdir -p /mattermost/data \
    && if [ "$edition" = "team" ] ; then curl https://releases.mattermost.com/$MM_VERSION/mattermost-team-$MM_VERSION-linux-amd64.tar.gz | tar -xvz ; \
      else curl https://releases.mattermost.com/$MM_VERSION/mattermost-$MM_VERSION-linux-amd64.tar.gz | tar -xvz ; fi \
    && cp /mattermost/config/config.json /config.json.save \
    && rm -Rf /mattermost/config/config.json 

# Get ready for production
RUN addgroup -g ${PGID} mattermost \
    && adduser -D -u ${PUID} -G mattermost mattermost \
    && chown -R mattermost: /mattermost \
    && apk update \
    && apk del curl \
    && rm -rf /tmp/* 

USER mattermost

# Configure entrypoint and command
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /mattermost
CMD ["platform"]

# Expose port 8000 of the container
EXPOSE 8000

# Use a volume for the data directory
VOLUME /mattermost/data
