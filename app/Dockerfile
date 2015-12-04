FROM ubuntu:14.04

RUN apt-get update && apt-get -y upgrade && apt-get -y install wget
RUN mkdir -p /mattermost/data

RUN touch /etc/init/mattermost.conf
RUN echo $'start on runlevel [2345]\n\
stop on runlevel [016]\n\
respawn\n\
chdir /mattermost\n\
exec bin/platform\n'\
>> /etc/init/mattermost.conf

RUN wget https://github.com/mattermost/platform/releases/download/v1.2.1/mattermost.tar.gz \
	&& tar -xvzf mattermost.tar.gz && rm mattermost.tar.gz

COPY config.template.json /
COPY docker-entry.sh /

RUN chmod +x /docker-entry.sh
ENTRYPOINT /docker-entry.sh

EXPOSE 80
