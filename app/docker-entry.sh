#!/bin/bash

DB_HOST=${DB_HOST:-db}
DB_PORT_5432_TCP_PORT=${DB_PORT_5432_TCP_PORT:-5432}
MM_USERNAME=${MM_USERNAME:-mmuser}
MM_PASSWORD=${MM_PASSWORD:-mmuser_password}
MM_DBNAME=${MM_DBNAME:-mattermost}
MM_CONFIG=/mattermost/config/config.json

if [ "${1:0:1}" = '-' ]; then
    set -- platform "$@"
fi

if [ "$1" = 'platform' ]; then
    for ARG in $@;
    do
        case "$ARG" in
            -config=*)
                MM_CONFIG=${ARG#*=};;
        esac
    done

    echo "Using config file" $MM_CONFIG

    echo -ne "Configure database connection..."
    if [ ! -f $MM_CONFIG ]
    then
        cp /config.template.json $MM_CONFIG
        sed -Ei "s/DB_HOST/$DB_HOST/" $MM_CONFIG
        sed -Ei "s/DB_PORT/$DB_PORT_5432_TCP_PORT/" $MM_CONFIG
        sed -Ei "s/MM_USERNAME/$MM_USERNAME/" $MM_CONFIG
        sed -Ei "s/MM_PASSWORD/$MM_PASSWORD/" $MM_CONFIG
        sed -Ei "s/MM_DBNAME/$MM_DBNAME/" $MM_CONFIG
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
fi

exec "$@"
