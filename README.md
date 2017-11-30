# Production Docker deployment for Mattermost

This project enables deployment of a Mattermost server in a multi-node production configuration using Docker.

[![Build Status](https://travis-ci.org/mattermost/mattermost-docker.svg?branch=master)](https://travis-ci.org/mattermost/mattermost-docker)

Notes:
- The default Mattermost edition for this repo has changed from Team Edition to Enterprise Edition. Please see [Choose Edition](#choose-edition-to-install) section.
- To install this Docker project on AWS Elastic Beanstalk please see [AWS Elastic Beanstalk Guide](contrib/aws/README.md).
- To run Mattermost on Kubernetes you can start with the [manifest examples in the kubernetes folder](contrib/kubernetes/README.md)
- To install Mattermost without Docker directly onto a Linux-based operating systems, please see [Admin Guide](https://docs.mattermost.com/guides/administrator.html#installing-mattermost).

## Installation using Docker Compose

The following instructions deploy Mattermost in a production configuration using multi-node Docker Compose set up.

### Requirements

For version 2.0 of docker-compose files:

* [docker] (version `1.10.0+`)
* [docker-compose] (version `1.6.0+` to support Compose file version `2.0`)


For version 3.0 of docker-compose files:

* [docker] (version `1.13.0+`)
* [docker-compose] (version `1.10.0+` to support Compose file version `3.0`)

*see:* [Composer releases after 1.11.0](https://github.com/docker/compose/releases?after=1.11.0)

### Choose Edition to Install

If you want to install Enterprise Edition, you can skip this section.

To install the team edition, comment out the two following lines in docker-compose.yaml file:
```yaml
args:
  - edition=team
```
The `app` Dockerfile will read the `edition` build argument to install Team (`edition = 'team'`) or Entreprise (`edition != team`) edition.

### Choose docker-compose edition / version to use.

We give you two docker-compose sample files, one supports version 3.0 of docker-compose, and the other one supports version 2.0 of docker-compose (you can see more of docker-compose file versions [here](https://docs.docker.com/compose/compose-file/), [here](https://docs.docker.com/compose/compose-file/compose-file-v2/), and [here](https://docs.docker.com/compose/compose-file/compose-versioning/)).

You have to get in mind the requirements for v2 and for v3, and the features that has the v3 over v2 (swarm support, and others); you can see more on [upgrading version 2.x to 3.x ](https://docs.docker.com/compose/compose-file/compose-versioning/#upgrading), and discussions about it:

* https://github.com/mattermost/mattermost-docker/issues/104
* https://forum.mattermost.org/t/mattermost-with-docker-discussion-about-requirements/3518
* https://github.com/mattermost/mattermost-docker/issues/151

You only have to do is:

```bash
$ mv docker-compose.v2.yml.sample docker-compose.yml
```

to use docker-compose version 2, or:

```bash
$ mv docker-compose.v3.yml.sample docker-compose.yml
```

to use docker-compose version 3.

Easy, right?

### Environment file.

We move the environment variables to a .env file; we give you an environment sample file `.env.sample`.

The only thing that you have to do, is:

```bash
$ mv .env.sample .env
```

And fill the vars with your values.


### Database container
This repository offer a Docker image for the Mattermost database. It is a customized PostgreSQL image that you should configure with following environment variables :
* `POSTGRES_USER`: database username
* `POSTGRES_PASSWORD`: database password
* `POSTGRES_DB`: database name

It is possible to use your own PostgreSQL database, or even use MySQL. But you will need to ensure that Application container can connect to the database (see [Application container](#application-container))

#### AWS
If deploying to AWS, you could also set following variables to enable [Wal-E](https://github.com/wal-e/wal-e) backup to S3 :
* `AWS_ACCESS_KEY_ID`: AWS access key
* `AWS_SECRET_ACCESS_KEY`: AWS secret
* `WALE_S3_PREFIX`: AWS s3 bucket name
* `AWS_REGION`: AWS region

All four environment variables are required. It will enable completed WAL segments sent to archive storage (S3). The base backup and clean up can be done through the following command:
```bash
# Base backup
docker exec mattermost-db su - postgres sh -c "/usr/bin/envdir /etc/wal-e.d/env /usr/local/bin/wal-e backup-push /var/lib/postgresql/data"
# Keep the most recent 7 base backups and remove the old ones
docker exec mattermost-db su - postgres sh -c "/usr/bin/envdir /etc/wal-e.d/env /usr/local/bin/wal-e delete --confirm retain 7"
```
Those tasks can be executed through a cron job or systemd timer.

### Application container
Application container run the Mattermost application. You should configure it with following environment variables :
* `MM_USERNAME`: database username
* `MM_PASSWORD`: database password
* `MM_DBNAME`: database name

If your database use some custom host and port, it is also possible to configure them :
* `DB_HOST`: database host address
* `DB_PORT_NUMBER`: database port

If you use a Mattermost configuration file on a different location than the default one (`/mattermost/config/config.json`) :
* `MM_CONFIG`: configuration file location inside the container.

If you choose to use MySQL instead of PostgreSQL, you should set a different datasource and SQL driver :
* `DB_PORT_NUMBER` : `3306`
* `MM_SQLSETTINGS_DRIVERNAME` : `mysql`
* `MM_SQLSETTINGS_DATASOURCE` : `MM_USERNAME:MM_PASSWORD@tcp(DB_HOST:DB_PORT_NUMBER)/MM_DBNAME?charset=utf8mb4,utf8&readTimeout=30s&writeTimeout=30s`
Don't forget to replace all entries (beginning by `MM_` and `DB_`) in `MM_SQLSETTINGS_DATASOURCE` with the real variables values.

### Web server container
This image is optional, you should **not** use it when you have your own reverse-proxy. It is a simple front Web server for the Mattermost app container. If you use the provided `docker-compose.yml` file, you don't have to configure anything. But if your application container is reachable on custom host and/or port (eg. if you use a container provider), you should add those two environment variables :
* `APP_HOST`: application host address
* `APP_PORT_NUMBER`: application HTTP port

#### Install with SSL certificate
Put your SSL certificate as `./volumes/web/cert/cert.pem` and the private key that has
no password as `./volumes/web/cert/key-no-password.pem`. If you don't have
them you may generate a self-signed SSL certificate.

### Building images

Before start the containers, we must to build the images:

```
docker-compose build
```

### Starting/Stopping Docker

#### Start
```
docker-compose start
```

#### Stop
```
docker-compose stop
```

### Removing Docker

#### Remove the containers
```
docker-compose stop && docker-compose rm
```

#### Remove the data and settings of your Mattermost instance
```
sudo rm -rf volumes
```

## Update Mattermost to latest version

First, shutdown your containers to back up your data.

```
docker-compose down
```

Back up your mounted volumes to save your data. If you use the default `docker-compose.yml` file proposed on this repository, your data is on `./volumes/` folder.

Then run the following commands.

```
git pull
docker-compose build
docker-compose up -d
```

Your Docker image should now be on the latest Mattermost version.

## Upgrading to Team Edition 3.0.x from 2.x

You need to migrate your database before upgrading Mattermost to `3.0.x` from
`2.x`. Run these commands in the latest `mattermost-docker` directory.
```
docker-compose rm -f app
docker-compose build app
docker-compose run app -upgrade_db_30
docker-compose up -d
```
See the [offical Upgrade Guide](http://docs.mattermost.com/administration/upgrade.html) for more details.

## Installation using Docker Swarm Mode

The following instructions deploy Mattermost in a production configuration using docker swarm mode on one node.
Running containerized applications on multi-node swarms involves specific data portability and replication handling that are not covered here.

### Requirements

* [docker] (1.12.0+)

### Swarm Mode Installation

First, create mattermost directory structure on the docker hosts:
```
mkdir -p /var/lib/mattermost/{cert,config,data,logs}
```

Then, fire up the stack in your swarm:
```
docker stack deploy -c contrib/swarm/docker-stack.yml mattermost
```

## Known Issues

* Do not modify the Listen Address in Service Settings.
* Rarely `app` container fails to start because of "connection refused" to
  database. Workaround: Restart the container.

## More information

If you want to know how to use docker-compose, see [the overview
page](https://docs.docker.com/compose).

For the server configurations, see [prod-ubuntu.rst] of Mattermost.

[docker]: http://docs.docker.com/engine/installation/
[docker-compose]: https://docs.docker.com/compose/install/
[prod-ubuntu.rst]: https://docs.mattermost.com/install/install-ubuntu-1404.html
