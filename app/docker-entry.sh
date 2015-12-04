#!/bin/bash
echo Starting Platform
config=/mattermost/config/config.json
if [ ! -f $config ]; then
    cp /config.template.json $config
    sed -Ei "s/PG_ADDR/$PG_PORT_5432_TCP_ADDR/" $config
    sed -Ei "s/PG_PORT/$PG_PORT_5432_TCP_PORT/" $config
fi
cd /mattermost/bin
./platform
