FROM ubuntu:14.04

RUN apt-get update && apt-get -y upgrade && apt-get -y install wget netcat
RUN mkdir -p /mattermost/data

RUN touch /etc/init/mattermost.conf
RUN echo $'start on runlevel [2345]\n\
stop on runlevel [016]\n\
respawn\n\
chdir /mattermost\n\
exec bin/platform\n'\
>> /etc/init/mattermost.conf

COPY mattermost-ent.tar.gz /
RUN tar -xvzf mattermost-ent.tar.gz && rm mattermost-ent.tar.gz

COPY config.template.json /
COPY docker-entry.sh /

RUN chmod +x /docker-entry.sh
ENTRYPOINT /docker-entry.sh

EXPOSE 80
