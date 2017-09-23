#!/bin/bash
if [ -f "/cert/cert.pem" -a -f "/cert/key-no-password.pem" ]; then
  echo "found certificate and key, linking ssl config"
  ssl="-ssl"
else
  echo "linking plain config"
fi
if [ -e "/etc/nginx/conf.d/default.conf" ]; then rm /etc/nginx/conf.d/default.conf; fi
ln -s /etc/nginx/sites-available/mattermost${ssl}.conf /etc/nginx/conf.d/mattermost.conf
nginx -g 'daemon off;'
