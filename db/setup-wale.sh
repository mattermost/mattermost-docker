#!/bin/bash

# wal-e specific
echo "wal_level = $WAL_LEVEL" >> $PGDATA/postgresql.conf
echo "archive_mode = $ARCHIVE_MODE" >> $PGDATA/postgresql.conf
echo "archive_command = 'envdir /etc/wal-e.d/env /usr/local/bin/wal-e wal-push %p'" >> $PGDATA/postgresql.conf
echo "archive_timeout = $ARCHIVE_TIMEOUT" >> $PGDATA/postgresql.conf

# no cron in the image, use systemd timer on host instead
#su - postgres -c "crontab -l | { cat; echo \"0 3 * * * /usr/bin/envdir /etc/wal-e.d/env /usr/local/bin/wal-e backup-push /var/lib/postgresql/data\"; } | crontab -"
#su - postgres -c "crontab -l | { cat; echo \"0 4 * * * /usr/bin/envdir /etc/wal-e.d/env /usr/local/bin/wal-e delete --confirm retain 7\"; } | crontab -"
