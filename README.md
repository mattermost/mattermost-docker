Dockerfiles for Mattermost in production

## Requirement

* [docker]
* [docker-compose]

## Installation

### Install with SSL certificate

1. Create a symbolic link `docker-compose.yml` to `docker-compose-ssl.yml`:

    ln -s docker-compose-ssl.yml docker-compose.yml

2. Put your SSL certificate as `web/cert/cert.pem` and the private key that has
   no password as `web/cert/private/key-no-password.pem`. If you don't have
   them you may generate a self-signed SSL certificate.

3. Build and run mattermost

    docker-compose up -d

4. Open `https://your.domain` with your web browser.

### Install without SSL certificate

1. Create a symbolic link `docker-compose.yml` to `docker-compose-nossl.yml`:

    ln -s docker-compose-nossl.yml docker-compose.yml

2. Build and run mattermost

    docker-compose up -d

3. Open `http://your.domain` with your web browser.

## Starting/Stopping

### Start

    docker-compose start

### Stop

    docker-compose stop

## Removing

### Remove the containers

    docker-compose stop && docker-compose rm

### Remove the data and settings of your mattermost instance

    sudo rm -rf volumes

## Database Backup

When AWS S3 environment variables are specified on db docker container, it enables [Wel-E](https://github.com/wal-e/wal-e) backup to S3.

```bash
docker run -d --name mattermost-db \
    -e AWS_ACCESS_KEY_ID=XXXX \
    -e AWS_SECRET_ACCESS_KEY=XXXX \
    -e WALE_S3_PREFIX=s3://BUCKET_NAME/PATH \
    -e AWS_REGION=us-east-1
    -v ./volumes/db/var/lib/postgresql/data:/var/lib/postgresql/data
    -v /etc/localtime:/etc/localtime:ro
    db
```

All four environment variables are required. It will enable completed WAL segments sent to archive storage (S3). The base backup and clean up can be done through the following command:

```bash
# base backup
docker exec mattermost-db su - postgres sh -c "/usr/bin/envdir /etc/wal-e.d/env /usr/local/bin/wal-e backup-push /var/lib/postgresql/data"
# keep the most recent 7 base backups and remove the old ones
docker exec mattermost-db su - postgres sh -c "/usr/bin/envdir /etc/wal-e.d/env /usr/local/bin/wal-e delete --confirm retain 7"
```
Those tasks can be executed through a cron job or systemd timer.

## Known Issues

* Do not modify the Listen Address in Service Settings.
* Rarely 'app' container fails to start because of "connection refused" to
  database. Workaround: Restart the container.

## More informations

If you want to know how to use docker-compose, see [the overview
page](https://docs.docker.com/compose).

For the server configurations, see [prod-ubuntu.rst] of mattermost.

[docker]: http://docs.docker.com/engine/installation/
[docker-compose]: https://docs.docker.com/compose/install/
[prod-ubuntu.rst]: https://github.com/mattermost/docs/blob/master/source/install/prod-ubuntu.rst
