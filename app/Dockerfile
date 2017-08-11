FROM ubuntu:14.04

# Some ENV variables
ENV PATH="/mattermost/bin:${PATH}"
ENV MM_VERSION=4.0.2

# Install some needed packages
RUN apt-get update \
    && apt-get -y install \
      curl \
      jq \
      netcat \
    && rm -rf /var/lib/apt/lists/*

# Prepare Mattermost
RUN mkdir -p /mattermost/data \
    && curl https://releases.mattermost.com/$MM_VERSION/mattermost-team-$MM_VERSION-linux-amd64.tar.gz | tar -xvz \
    && cp /mattermost/config/config.json /config.json.save \
    && rm -rf /mattermost/config/config.json

# Configure entrypoint
COPY docker-entry.sh /
# Set permission (TODO should be removed and replace by a chmod on the file in the repository ?)
RUN chmod +x /docker-entry.sh
ENTRYPOINT ["/docker-entry.sh"]

EXPOSE 80

VOLUME /mattermost/data

WORKDIR /mattermost/bin
CMD ["platform"]
