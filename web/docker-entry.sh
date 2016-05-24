#!/bin/bash
echo Starting Nginx
sed -Ei "s/PLATFORM_PORT/$PLATFORM_PORT_80_TCP_PORT/" /etc/nginx/sites-available/mattermost
nginx -g 'daemon off;'
