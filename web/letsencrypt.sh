#!/bin/sh
if [ ${LETSENCRYPT_SSL_GENERATION} ]; then
  echo "Running certificate generation from Letsencrypt."
  certbot -m ${EMAIL} -d ${DOMAIN_NAME} --agree-tos -n --nginx

  # try to run renew certificate every day
  echo "@midnight * * * * certbot renew" | crontab

  #run cron
  cron
else
  echo "Not running certificate generation from Letsencrypt."
fi
