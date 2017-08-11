#!/bin/bash

generate_salt() {
  cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 48 | head -n 1
}

DB_HOST=${DB_HOST:-db}
DB_PORT_NUMBER=${DB_PORT_NUMBER:-5432}
MM_USERNAME=${MM_USERNAME:-mmuser}
MM_PASSWORD=${MM_PASSWORD:-mmuser_password}
MM_DBNAME=${MM_DBNAME:-mattermost}
MM_CONFIG=${MM_CONFIG:-/mattermost/config/config.json}

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


    if [ ! -f $MM_CONFIG ]
    then
      echo "No configuration file" $MM_CONFIG
      echo "Creating a new one"
      # Copy default configuration file
      cp /config.json.save $MM_CONFIG
      # Substitue some parameters with jq
      jq '.ServiceSettings.ListenAddress = ":80"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
      jq '.LogSettings.EnableConsole = false' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
      jq '.LogSettings.ConsoleLevel = "INFO"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
      jq '.FileSettings.Directory = "/mattermost/data/"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
      jq '.FileSettings.EnablePublicLink = true' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
      jq '.FileSettings.PublicLinkSalt = "'$(generate_salt)'"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
      jq '.EmailSettings.SendEmailNotifications = false' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
      jq '.EmailSettings.FeedbackEmail = ""' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
      jq '.EmailSettings.SMTPServer = ""' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
      jq '.EmailSettings.SMTPPort = ""' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
      jq '.EmailSettings.InviteSalt = "'$(generate_salt)'"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
      jq '.EmailSettings.PasswordResetSalt = "'$(generate_salt)'"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
      jq '.RateLimitSettings.Enable = true' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
      jq '.SqlSettings.DriverName = "postgres"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
      jq '.SqlSettings.AtRestEncryptKey = "'$(generate_salt)'"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
    else
      echo "Using existing config file" $MM_CONFIG
    fi

    if [ -z "$MM_SQLSETTINGS_DATASOURCE"]
    then
      echo -ne "Configure database connection..."
      export MM_SQLSETTINGS_DATASOURCE="postgres://$MM_USERNAME:$MM_PASSWORD@$DB_HOST:$DB_PORT_NUMBER/$MM_DBNAME?sslmode=disable&connect_timeout=10"
      echo OK
    else
      echo "Using existing database connection"
    fi

    echo "Wait until database $DB_HOST:$DB_PORT_NUMBER is ready..."
    until nc -z $DB_HOST $DB_PORT_NUMBER
    do
        sleep 1
    done

    # Wait to avoid "panic: Failed to open sql connection pq: the database system is starting up"
    sleep 1

    echo "Starting platform"
fi

exec "$@"
