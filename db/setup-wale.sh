#!/bin/bash

# wal-e specific
echo "wal_level = $WAL_LEVEL" >> $PGDATA/postgresql.conf
echo "archive_mode = $ARCHIVE_MODE" >> $PGDATA/postgresql.conf
echo "archive_command = 'envdir /etc/wal-e.d/env /usr/local/bin/wal-e wal-push %p'" >> $PGDATA/postgresql.conf
echo "archive_timeout = $ARCHIVE_TIMEOUT" >> $PGDATA/postgresql.conf
