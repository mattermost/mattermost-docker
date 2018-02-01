FROM ubuntu:16.04

# Some ENV variables
ENV PATH="/mattermost/bin:${PATH}"
ENV MM_VERSION=4.6.1

# Build argument to set Mattermost edition
ARG edition=enterprise

# Install some needed packages
RUN apt-get update \
    && apt-get -y --no-install-recommends install \
      curl \
      jq \
      netcat \
      ca-certificates \
      xmlsec1 \
      mime-support \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin

# Get Mattermost
RUN mkdir -p /mattermost/data \
    && if [ "$edition" = "team" ] ; then curl https://releases.mattermost.com/$MM_VERSION/mattermost-team-$MM_VERSION-linux-amd64.tar.gz | tar -xvz ; \
      else curl https://releases.mattermost.com/$MM_VERSION/mattermost-$MM_VERSION-linux-amd64.tar.gz | tar -xvz ; fi \
    && cp /mattermost/config/config.json /config.json.save \
    && rm -rf /mattermost/config/config.json

# Configure entrypoint and command
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /mattermost
CMD ["platform"]

# Expose port 80 of the container
EXPOSE 80

# Use a volume for the data directory
VOLUME /mattermost/data
