FROM alpine:3.9

# Some fix ENV variables
ENV PATH="/mattermost/bin:${PATH}"

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
	tzdata \
	su-exec \
	&& rm -rf /tmp/*

# Build argument to set Mattermost edition
ARG edition=enterprise
ARG MM_VERSION=5.13.0
ARG MM_BINARY=""

# Some flexible ENV variables
ENV EDITION=${edition}}    
ENV MM_VERSION="${MM_VERSION}"


# Get Mattermost
RUN set -eu \
	;mkdir -p /mattermost/data /mattermost/plugins /mattermost/client/plugins \
	;if [ ! -z "${MM_BINARY-}" ]; then curl -L $MM_BINARY | tar x -vzf - \
      ;elif [ "$edition" = "team" ] ; then curl -L https://releases.mattermost.com/${MM_VERSION}/mattermost-team-$MM_VERSION-linux-amd64.tar.gz | tar x -vzf - \
      ;else curl -L https://releases.mattermost.com/${MM_VERSION}/mattermost-$MM_VERSION-linux-amd64.tar.gz | tar x -vzf - ; fi \
    ;cp /mattermost/config/config.json /config.json.save \
    ;rm -rf /mattermost/config/config.json \
	;


#Healthcheck to make sure container is ready
HEALTHCHECK CMD curl --fail http://localhost:8000 || exit 1

# Configure entrypoint and command
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /mattermost
CMD ["mattermost"]

# Expose port 8000 of the container
EXPOSE 8000

# Declare volumes for mount point directories
#VOLUME ["/mattermost/data", "/mattermost/logs", "/mattermost/config", "/mattermost/plugins", "/mattermost/client/plugins"]
