FROM nginx

# install cron, supervisor and certbot
RUN echo "deb http://ftp.debian.org/debian stretch-backports main" | tee -a /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -qy cron supervisor python-certbot-nginx -t stretch-backports

# Remove default configuration and add our custom Nginx configuration files
RUN rm /etc/nginx/conf.d/default.conf
COPY ./mattermost /etc/nginx/sites-available/
COPY ./mattermost-ssl /etc/nginx/sites-available/
COPY ./security.conf /etc/nginx/conf.d/

# Add entrypoint script and letsencrypt script
COPY entrypoint.sh letsencrypt.sh /usr/bin/

RUN chmod +x /usr/bin/entrypoint.sh /usr/bin/letsencrypt.sh

# Supervisor config
COPY entrypoint.conf /etc/supervisor/conf.d/

# Run Supervisor
CMD ["supervisord", "-n"]
