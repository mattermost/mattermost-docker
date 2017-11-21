FROM alpine

# Some ENV variables
ENV PATH="/mattermost/bin:${PATH}"
ENV MM_VERSION=4.4.1

# Build argument to set Mattermost edition
ARG edition=entreprise


RUN apk add --no-cache --virtual .build-deps \
	netcat-openbsd \
	jq \
	curl \
	ca-certificates \
	linux-headers \
    libffi-dev \
    libc6-compat \
    bash \
    ca-certificates \
    build-base \
	&& rm -rf /var/cache/apk/* \
	&& apk del .build-deps 
	
# Get Mattermost
RUN mkdir -p /mattermost/data \
    && if [ "$edition" = "team" ] ; then curl https://releases.mattermost.com/$MM_VERSION/mattermost-team-$MM_VERSION-linux-amd64.tar.gz | tar -xvz ; \
      else curl https://releases.mattermost.com/$MM_VERSION/mattermost-$MM_VERSION-linux-amd64.tar.gz | tar -xvz ; fi \
    && cp /mattermost/config/config.json /config.json.save \
    && rm -rf /mattermost/config/config.json

# Configure entrypoint and command
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /mattermost/bin
CMD ["platform"]

# Expose port 80 of the container
EXPOSE 80

# Use a volume for the data directory
VOLUME /mattermost/data
