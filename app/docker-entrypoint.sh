#!/bin/bash -eux

generate_salt() {
  cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 48 | head -n 1
}

chown -R mattermost:mattermost /opt/mattermost
chmod -R g+w /opt/mattermost

config=/opt/mattermost/config/config.json
echo -ne "Configure database connection..."

if [ ! -f $config ]
then
  cp /config.template.json $config
  sed -Ei "s/POSTGRES_PASSWORD/$POSTGRES_PASSWORD/" $config
  for key in \
    ChangeInviteSalt \
    ChangePublicLinkSalt \
    ChangePasswordResetSalt \
    ChangeAtRestEncryptKey
  do
    echo "Generating and setting salt for '$key'..."
    sed -Ei "s/$key/`generate_salt`/" $config
  done
  echo OK
else
  echo SKIP
fi

echo "Wait until database is ready..."
while ! timeout 1 bash -c 'cat < /dev/null > /dev/tcp/db/5432' >/dev/null 2>/dev/null; do sleep 0.1; done

# Wait to avoid "panic: Failed to open sql connection pq: the database system is starting up"
sleep 1

echo "Starting platform"
cd /opt/mattermost/bin
gosu mattermost ./platform $*
