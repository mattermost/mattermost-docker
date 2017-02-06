#!/bin/sh
echo Starting Nginx
sed -Ei "s/APP_PORT/$PLATFORM_PORT_80_TCP_PORT/" /etc/nginx/sites-available/mattermost
sed -Ei "s/APP_PORT/$PLATFORM_PORT_80_TCP_PORT/" /etc/nginx/sites-available/mattermost-ssl
if [ "$MATTERMOST_ENABLE_SSL" = true ]; then
    ssl="-ssl"
fi
ln -s /etc/nginx/sites-available/mattermost$ssl /etc/nginx/conf.d/mattermost.conf
nginx -g 'daemon off;'
