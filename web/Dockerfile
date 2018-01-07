FROM nginx

# install certbot
RUN apt-get install -qy supervisor python-certbot-nginx -t stretch-backports

# Remove default configuration and add our custom Nginx configuration files
RUN rm /etc/nginx/conf.d/default.conf
COPY ./mattermost /etc/nginx/sites-available/
COPY ./mattermost-ssl /etc/nginx/sites-available/
COPY ./security.conf /etc/nginx/conf.d/

# Add and setup entrypoint
COPY nginx.sh letsencrypt.sh /usr/bin/

RUN chmod +x /usr/bin/nginx.sh /usr/bin/letsencrypt.sh

# Supervisor config
COPY nginx.conf letsencrypt.conf /etc/supervisor/conf.d/

COPY entrypoint.sh /
CMD ["supervisord", "-n"]
