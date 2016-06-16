FROM debian:jessie

RUN apt-get update && apt-get -y install curl \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /opt/mattermost/data \
 && useradd -r mattermost -U \
 && cd /opt \
 && curl https://releases.mattermost.com/3.0.2/mattermost-team-3.0.2-linux-amd64.tar.gz | tar -xvz

# grab gosu for easy step-down from root
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.3/gosu-$(dpkg --print-architecture)" \
 && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.3/gosu-$(dpkg --print-architecture).asc" \
 && gpg --verify /usr/local/bin/gosu.asc \
 && rm /usr/local/bin/gosu.asc \
 && chmod +x /usr/local/bin/gosu

COPY config.template.json /
COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8080
