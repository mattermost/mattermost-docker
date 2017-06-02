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
    if [ ! -f $MM_CONFIG ]
    then
        cp /config.json.save $MM_CONFIG
    fi

    echo -ne "Configure database connection..."
    export MM_SQLSETTINGS_DATASOURCE="postgres://$MM_USERNAME:$MM_PASSWORD@$DB_HOST:$DB_PORT/$MM_DBNAME?sslmode=disable&connect_timeout=10"
    echo OK

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
