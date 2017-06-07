FROM ubuntu:14.04

# Some ENV variables
ENV PATH="/mattermost/bin:${PATH}"
ENV MM_VERSION=3.9.0

# Override default config
ENV MM_SERVICESETTINGS_LISTENADDRESS=":80" \
    MM_LOGSETTINGS_ENABLECONSOLE=false \
    MM_LOGSETTINGS_CONSOLELEVEL="INFO" \
    MM_FILESETTINGS_DIRECTORY="/mattermost/data/" \
    MM_FILESETTINGS_ENABLEPUBLICLINK=true \
    MM_FILESETTINGS_PUBLICLINKSALT="A705AklYF8MFDOfcwh3I488G8vtLlVip" \
    MM_EMAILSETTINGS_SENDEMAILNOTIFICATIONS=false \
    MM_EMAILSETTINGS_FEEDBACKEMAIL="" \
    MM_EMAILSETTINGS_SMTPSERVER="" \
    MM_EMAILSETTINGS_SMTPPORT="" \
    MM_EMAILSETTINGS_INVITESALT="bjlSR4QqkXFBr7TP4oDzlfZmcNuH9YoS" \
    MM_RATELIMITSETTINGS_ENABLE=true \
    MM_SQLSETTINGS_DRIVERNAME="postgres"

# Install some needed packages
RUN apt-get update \
    && apt-get -y install \
      curl \
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
