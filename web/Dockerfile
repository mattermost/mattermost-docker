FROM nginx:alpine

RUN rm /etc/nginx/conf.d/default.conf

COPY mattermost /etc/nginx/sites-available/
COPY mattermost-ssl /etc/nginx/sites-available/
ADD docker-entry.sh /

COPY docker-entry.sh /
RUN chmod +x /docker-entry.sh
ENTRYPOINT /docker-entry.sh
