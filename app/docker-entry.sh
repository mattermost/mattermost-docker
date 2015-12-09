#!/bin/bash
config=/mattermost/config/config.json
echo -ne "Configure database connection..."
if [ ! -f $config ]
then
    cp /config.template.json $config
    sed -Ei "s/PG_ADDR/$PG_PORT_5432_TCP_ADDR/" $config
    sed -Ei "s/PG_PORT/$PG_PORT_5432_TCP_PORT/" $config
    echo OK
else
    echo SKIP
fi

echo -n "Wait until database is ready..."
until nc -z $PG_PORT_5432_TCP_ADDR $PG_PORT_5432_TCP_PORT
do
    echo -n .
    sleep 1
done

# Wait to avoid "panic: Failed to open sql connection pq: the database system is starting up"
sleep 1

echo "OK"

echo "Starting platform"
cd /mattermost/bin
./platform
