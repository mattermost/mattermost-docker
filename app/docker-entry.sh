#!/bin/bash
config=/mattermost/config/config.json
DB_HOST=${DB_HOST:-db}
DB_PORT_5432_TCP_PORT=${DB_PORT_5432_TCP_PORT:-5432}
MM_USERNAME=${MM_USERNAME:-mmuser}
MM_PASSWORD=${MM_PASSWORD:-mmuser_password}
MM_DBNAME=${MM_DBNAME:-mattermost}
echo -ne "Configure database connection..."
if [ ! -f $config ]
then
    cp /config.template.json $config
    sed -Ei "s/DB_HOST/$DB_HOST/" $config
    sed -Ei "s/DB_PORT/$DB_PORT_5432_TCP_PORT/" $config
    sed -Ei "s/MM_USERNAME/$MM_USERNAME/" $config
    sed -Ei "s/MM_PASSWORD/$MM_PASSWORD/" $config
    sed -Ei "s/MM_DBNAME/$MM_DBNAME/" $config
    echo OK
else
    echo SKIP
fi

echo "Wait until database $DB_HOST:$DB_PORT_5432_TCP_PORT is ready..."
until nc -z $DB_HOST $DB_PORT_5432_TCP_PORT
do
    sleep 1
done

# Wait to avoid "panic: Failed to open sql connection pq: the database system is starting up"
sleep 1

echo "Starting platform"
cd /mattermost/bin
./platform $*
