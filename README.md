# Production Docker deployment for Mattermost

This project enables deployment of a Mattermost server in a multi-node production configuration using Docker. 

[![Build Status](https://travis-ci.org/mattermost/mattermost-docker.svg?branch=master)](https://travis-ci.org/mattermost/mattermost-docker)

Notes: 
- To install this Docker project on AWS Elastic Beanstalk please see [AWS Elastic Beanstalk Guide](./README.aws.md).
- To install Mattermost without Docker directly onto a Linux-based operating systems, please see [Admin Guide](https://docs.mattermost.com/guides/administrator.html#installing-mattermost).

## Installation using Docker Compose 

The following instructions deploy Mattermost in a production configuration using multi-node Docker Compose set up. 

### Requirements

* [docker]
* [docker-compose]

### Install with SSL certificate

1. Open docker-compose.yml and set `MATTERMOST_ENABLE_SSL` to true.

    ```
    environment:
      - MATTERMOST_ENABLE_SSL=true
    ```

2. Put your SSL certificate as `./volumes/web/cert/cert.pem` and the private key that has
   no password as `./volumes/web/cert/key-no-password.pem`. If you don't have
   them you may generate a self-signed SSL certificate.

3. Build and run mattermost

    docker-compose up -d

4. Open `https://your.domain` with your web browser.

### Install without SSL certificate

1. Open docker-compose.yml and set `MATTERMOST_ENABLE_SSL` to false.

    ```
    environment:
      - MATTERMOST_ENABLE_SSL=false
    ```
    
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

When AWS S3 environment variables are specified on db docker container, it enables [Wal-E](https://github.com/wal-e/wal-e) backup to S3.

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

## Upgrading to Team Edition 3.0.x from 2.x

You need to migrate your database before upgrading mattermost to 3.0.x from
2.x. Run these commands in the latest mattermost-docker directory.

    docker-compose rm -f app
    docker-compose build app
    docker-compose run app -upgrade_db_30
    docker-compose up -d

See the [offical Upgrade Guide](http://docs.mattermost.com/administration/upgrade.html) for more details.

## Known Issues

* Do not modify the Listen Address in Service Settings.
* Rarely 'app' container fails to start because of "connection refused" to
  database. Workaround: Restart the container.

## More information

If you want to know how to use docker-compose, see [the overview
page](https://docs.docker.com/compose).

If you want to run Mattermost on Kubernetes you can start with the [manifest examples in the kubernetes folder](contrib/kubernetes/README.md)

For the server configurations, see [prod-ubuntu.rst] of mattermost.

[docker]: http://docs.docker.com/engine/installation/
[docker-compose]: https://docs.docker.com/compose/install/
[prod-ubuntu.rst]: https://docs.mattermost.com/install/install-ubuntu-1404.html
