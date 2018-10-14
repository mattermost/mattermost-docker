#!/bin/bash

# wal-e specific configuration
echo "wal_level = $WAL_LEVEL" >> $PGDATA/postgresql.conf
echo "archive_mode = $ARCHIVE_MODE" >> $PGDATA/postgresql.conf
echo "archive_command = '/usr/bin/wal-e wal-push %p'" >> $PGDATA/postgresql.conf
echo "archive_timeout = $ARCHIVE_TIMEOUT" >> $PGDATA/postgresql.conf

# envdir specific configuration setup
echo $AWS_ACCESS_KEY_ID > /etc/wal-e.d/env/AWS_ACCESS_KEY_ID
echo $AWS_SECRET_ACCESS_KEY > /etc/wal-e.d/env/AWS_SECRET_ACCESS_KEY
echo $WALE_S3_PREFIX > /etc/wal-e.d/env/WALE_S3_PREFIX
echo $AWS_REGION > /etc/wal-e.d/env/AWS_REGION