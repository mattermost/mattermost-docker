#!/bin/bash
echo Starting Platform
sed -Ei "s/PG_ADDR/$PG_PORT_5432_TCP_ADDR/" /config_docker.json
sed -Ei "s/PG_PORT/$PG_PORT_5432_TCP_PORT/" /config_docker.json
cd /mattermost/bin
./platform -config=/config_docker.json
