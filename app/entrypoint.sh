#!/bin/sh

# Function to generate a random salt
generate_salt() {
  tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 48 | head -n 1
}

# Read environment variables or set default values
DB_HOST=${DB_HOST:-db}
DB_PORT_NUMBER=${DB_PORT_NUMBER:-5432}
MM_DBNAME=${MM_DBNAME:-mattermost}
MM_CONFIG=${MM_CONFIG:-/mattermost/config/config.json}

if [ "${1:0:1}" = '-' ]; then
    set -- mattermost "$@"
fi

if [ "$1" = 'mattermost' ]; then
  # Check CLI args for a -config option
  for ARG in $@;
  do
      case "$ARG" in
          -config=*)
              MM_CONFIG=${ARG#*=};;
      esac
  done

  if [ ! -f $MM_CONFIG ]
  then
    # If there is no configuration file, create it with some default values
    echo "No configuration file" $MM_CONFIG
    echo "Creating a new one"
    # Copy default configuration file
    cp /config.json.save $MM_CONFIG
    # Substitue some parameters with jq
    jq '.ServiceSettings.ListenAddress = ":8000"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
    jq '.LogSettings.EnableConsole = true' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
    jq '.LogSettings.ConsoleLevel = "ERROR"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
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
    jq '.PluginSettings.Directory = "/mattermost/plugins/"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
  else
    echo "Using existing config file" $MM_CONFIG
  fi

  # Configure database access
  if [[ -z "$MM_SQLSETTINGS_DATASOURCE" && ! -z "$MM_USERNAME" && ! -z "$MM_PASSWORD" ]]
  then
    echo -ne "Configure database connection..."
    # URLEncode the password, allowing for special characters
    ENCODED_PASSWORD=$(printf %s $MM_PASSWORD | jq -s -R -r @uri)
    export MM_SQLSETTINGS_DATASOURCE="postgres://$MM_USERNAME:$ENCODED_PASSWORD@$DB_HOST:$DB_PORT_NUMBER/$MM_DBNAME?sslmode=disable&connect_timeout=10"
    echo OK
  else
    echo "Using existing database connection"
  fi

  # Wait another second for the database to be properly started.
  # Necessary to avoid "panic: Failed to open sql connection pq: the database system is starting up"
  sleep 1

  echo "Starting mattermost"
fi

exec "$@"
