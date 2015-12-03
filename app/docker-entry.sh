#!/bin/bash
echo Starting Platform
sed -Ei "s/PG_ADDR/$PG_PORT_5432_TCP_ADDR/" /mattermost/config/config.json
sed -Ei "s/PG_PORT/$PG_PORT_5432_TCP_PORT/" /mattermost/config/config.json
cd /mattermost/bin
./platform
