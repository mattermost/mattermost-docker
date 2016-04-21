#!/bin/bash

if [ "${1:0:1}" = '-'  ]; then
    set -- postgres "$@"
fi

if [ "$1" = 'postgres'  ]; then
    VARS=(AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY WALE_S3_PREFIX AWS_REGION)

    for v in ${VARS[@]}; do
        if [ "${!v}" = "" ]; then
            echo "$v is required for Wal-E but not set. Skipping Wal-E setup."
            . /docker-entrypoint.sh
            exit
        fi
    done

    umask u=rwx,g=rx,o=
    mkdir -p /etc/wal-e.d/env

    for v in ${VARS[@]}; do
        echo "${!v}" > /etc/wal-e.d/env/$v
    done
    chown -R root:postgres /etc/wal-e.d

    . /docker-entrypoint.sh
fi

exec "$@"
