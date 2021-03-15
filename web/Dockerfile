FROM nginxinc/nginx-unprivileged:mainline-alpine

USER root

# Remove default configuration and add our custom Nginx configuration files
RUN rm /etc/nginx/conf.d/default.conf \
    && apk add --no-cache curl

COPY ["./mattermost", "./mattermost-ssl", "/etc/nginx/sites-available/"]

# Add and setup entrypoint
COPY entrypoint.sh /

RUN chown -R nginx:nginx /etc/nginx/sites-available && \
         chown -R nginx:nginx /var/cache/nginx && \
         chown -R nginx:nginx /var/log/nginx && \
         chown -R nginx:nginx /etc/nginx/conf.d && \
         chown nginx:nginx entrypoint.sh
RUN touch /var/run/nginx.pid && \
         chown -R nginx:nginx /var/run/nginx.pid

COPY ./security.conf /etc/nginx/conf.d/

RUN chown -R nginx:nginx /etc/nginx/conf.d/security.conf

RUN chmod u+x /entrypoint.sh

RUN sed -i "/^http {/a \    proxy_buffering off;\n" /etc/nginx/nginx.conf
RUN sed -i '/temp_path/d' /etc/nginx/nginx.conf \
    && sed -i 's!/tmp/nginx.pid!/var/run/nginx.pid!g' /etc/nginx/nginx.conf

USER nginx

#Healthcheck to make sure container is ready
HEALTHCHECK CMD curl --fail http://localhost:8080 || exit 1

ENTRYPOINT ["/entrypoint.sh"]

VOLUME ["/var/run", "/etc/nginx/conf.d/", "/var/cache/nginx/"]

