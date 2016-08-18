#!/bin/bash

# if wal backup is not enabled, use minimal wal logging to reduce disk space
: ${WAL_LEVEL:=minimal}
: ${ARCHIVE_MODE:=off}
: ${ARCHIVE_TIMEOUT:=60}
# PGDATA is defined in upstream postgres dockerfile

function update_conf () {
    if [ -f $PGDATA/postgresql.conf ]; then
        sed -i "s/wal_level =.*$/wal_level = $WAL_LEVEL/g" $PGDATA/postgresql.conf
        sed -i "s/archive_mode =.*$/archive_mode = $ARCHIVE_MODE/g" $PGDATA/postgresql.conf
    fi
}

if [ "${1:0:1}" = '-'  ]; then
    set -- postgres "$@"
fi

if [ "$1" = 'postgres'  ]; then
    VARS=(AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY WALE_S3_PREFIX AWS_REGION)

    for v in ${VARS[@]}; do
        if [ "${!v}" = "" ]; then
            echo "$v is required for Wal-E but not set. Skipping Wal-E setup."
            update_conf
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

    WAL_LEVEL=archive
    ARCHIVE_MODE=on

    update_conf
    . /docker-entrypoint.sh
fi
