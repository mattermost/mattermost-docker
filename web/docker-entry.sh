#!/bin/bash
rm /etc/nginx/sites-enabled/mattermost-ssl
rm /etc/nginx/sites-enabled/mattermost
ln -s /etc/nginx/sites-available/mattermost-ssl /etc/nginx/sites-enabled/mattermost-ssl
nginx -g 'daemon off;'
