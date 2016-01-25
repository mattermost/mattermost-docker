#!/bin/bash
config=/mattermost/config/config.json
echo -ne "Configure database connection..."
if [ ! -f $config ]
then
    cp /config.template.json $config
    sed -Ei "s/DB_PORT/$DB_PORT_5432_TCP_PORT/" $config
    echo OK
else
    echo SKIP
fi

# Wait to avoid "panic: Failed to open sql connection pq: the database system is starting up"
echo "Wait until database is ready..."
until nc -z db $DB_PORT_5432_TCP_PORT
do
    sleep 1
done

echo "Starting platform"
cd /mattermost/bin
./platform
