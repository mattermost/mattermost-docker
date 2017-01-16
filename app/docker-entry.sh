#!/bin/bash
    config=/mattermost/config/config.json
if [ ! -f $config ]
then
    cp /config.json $config
    echo OK
else
    echo SKIP
fi

echo "Wait until database is ready..."
until nc -z celsus-dev.csage8mc3lg9.ap-southeast-1.rds.amazonaws.com 3306
do
    sleep 1
done

# Wait to avoid "panic: Failed to open sql connection pq: the database system is starting up"
sleep 1

echo "Starting platform"
cd /mattermost/bin
./platform $*
