FROM ubuntu:14.04

RUN apt-get update && apt-get -y install wget netcat
RUN mkdir -p /mattermost/data

RUN wget https://releases.mattermost.com/2.1.0/mattermost-team-2.1.0-linux-amd64.tar.gz \
	&& tar -xvzf mattermost-team-2.1.0-linux-amd64.tar.gz && rm mattermost-team-2.1.0-linux-amd64.tar.gz

COPY config.template.json /
COPY docker-entry.sh /

RUN chmod +x /docker-entry.sh
ENTRYPOINT /docker-entry.sh

EXPOSE 80
