#!/bin/bash

# if wal-e backup is not enabled, use minimal wal-e logging to reduce disk space
export WAL_LEVEL=${WAL_LEVEL:-minimal}
export ARCHIVE_MODE=${ARCHIVE_MODE:-off}
export ARCHIVE_TIMEOUT=${ARCHIVE_TIMEOUT:-60}

function update_conf () {
  wal=$1
  # PGDATA is defined in upstream postgres dockerfile
  config_file=$PGDATA/postgresql.conf

  # Check if configuration file exists. If not, it probably means that database is not initialized yet
  if [ ! -f $config_file ]; then
    return
  fi
  # Reinitialize config
  sed -i "s/log_timezone =.*$//g" $PGDATA/postgresql.conf
  sed -i "s/timezone =.*$//g" $PGDATA/postgresql.conf
  sed -i "s/wal_level =.*$//g" $config_file
  sed -i "s/archive_mode =.*$//g" $config_file
  sed -i "s/archive_timeout =.*$//g" $config_file
  sed -i "s/archive_command =.*$//g" $config_file

  # Configure wal-e
  if [ "$wal" = true ] ; then
    /docker-entrypoint-initdb.d/setup-wale.sh
  fi
  echo "log_timezone = $DEFAULT_TIMEZONE" >> $config_file
  echo "timezone = $DEFAULT_TIMEZONE" >> $config_file
}

if [ "${1:0:1}" = '-' ]; then
  set -- postgres "$@"
fi

if [ "$1" = 'postgres' ]; then
  # Check wal-e variables
  wal_enable=true
  VARS=(AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY WALE_S3_PREFIX AWS_REGION)
  for v in ${VARS[@]}; do
    if [ "${!v}" = "" ]; then
      echo "$v is required for Wal-E but not set. Skipping Wal-E setup."
      wal_enable=false
    fi
  done

  # Setup wal-e env variables
  if [ "$wal_enable" = true ] ; then
    for v in ${VARS[@]}; do
      export $v="${!v}"
    done
    WAL_LEVEL=archive
    ARCHIVE_MODE=on
  fi

  # Update postgresql configuration
  update_conf $wal_enable

  # Run the postgresql entrypoint
  . /docker-entrypoint.sh
fi
