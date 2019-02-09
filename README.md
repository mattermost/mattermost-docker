# Production Docker deployment for Mattermost

This project enables deployment of a Mattermost server in production using Docker.

[![Build Status](https://travis-ci.org/mattermost/mattermost-docker.svg?branch=master)](https://travis-ci.org/mattermost/mattermost-docker)

## Requirements

* [docker] (version `1.12+`)

## Docker images

This *repository* contains 2 Docker images (`app` and `db`) that allow you to run Mattermost using Docker.

### Application image

The `app` image is under the [`app`](app/) folder. This is the main Docker image, containing the Mattermost application ready to run. You can build the image yourself or use `mattermost/mattermost-prod-app` from [Docker Hub](mattermost/mattermost-prod-app).

If you want to build the image, you can run
```
docker build -t mattermost-app -f app/Dockerfile app/
```

You can customize the image using following build arguments :
- `edition`: By default the Mattermost Enterprise edition is built. If you set this to `team` it well build the Mattermost Team edition.
- `PUID`: Allow to change the UID of the user running Mattermost inside the container (default to `2000`)
- `PGID`: Allow to change the GID of the user running Mattermost inside the container (default to `2000`)
- `MM_BINARY`: Allow to change the URI used to get the Mattermost binary

For example, if you want to run the `team` edition you should run
```
docker build -t mattermost-app -f app/Dockerfile --build-arg edition=team app/
```

### Database image

Mattermost need a database in order to work. You can use your own PostgreSQL or MySQL database but we also provide a ready-to-run Docker image of PostgreSQL under [`db`](db/) folder.
You can build the image yourself or use `mattermost/mattermost-prod-db` from [Docker Hub](mattermost/mattermost-prod-db).


If you want to build the image, you can run
```
docker build -t mattermost-db -f db/Dockerfile db/
```

## Deploy

First, create a Docker network to connect your containers :
```
docker network create mattermost-net
```

### Database setup
It is possible to use your own PostgreSQL database, or even use MySQL. But you will need to ensure that Application container can connect to the database.

#### Configuration
If you use the custom database image on this repository, you can configure the container with following environment variables :
- `POSTGRES_USER`: database username
- `POSTGRES_PASSWORD`: database password
- `POSTGRES_DB`: database name

#### Volumes

To ensure data persistence you need to mount the `/var/lib/postgresql/data` to a Docker volume or bind mount. Also you should mount the `/etc/localtime` file inside the container.

#### Run

Considering this, here is an example of how to run the `db` container :
```
docker run -d --name mattermost-db --net mattermost-net --network-alias db \
-e POSTGRES_USER=mmuser -e POSTGRES_PASSWORD=mmuser_password -e POSTGRES_DB=mattermost \
-v /docker/volumes/mattermost/db/data:/var/lib/postgresql/data -v /etc/localtime:/etc/localtime:ro \
mattermost/mattermost-prod-db
```

#### AWS
If deploying to AWS, you could also set following variables to enable [Wal-E](https://github.com/wal-e/wal-e) backup to S3 :
- `AWS_ACCESS_KEY_ID`: AWS access key
- `AWS_SECRET_ACCESS_KEY`: AWS secret
- `WALE_S3_PREFIX`: AWS s3 bucket name
- `AWS_REGION`: AWS region

All four environment variables are required. It will enable completed WAL segments sent to archive storage (S3). The base backup and clean up can be done through the following command:
```bash
# Base backup
docker exec mattermost-db su - postgres sh -c "/usr/bin/envdir /etc/wal-e.d/env /usr/bin/wal-e backup-push /var/lib/postgresql/data"
# Keep the most recent 7 base backups and remove the old ones
docker exec mattermost-db su - postgres sh -c "/usr/bin/envdir /etc/wal-e.d/env /usr/bin/wal-e delete --confirm retain 7"
```
Those tasks can be executed through a cron job or systemd timer.

### Application setup

#### Configuration
The `app` container run the Mattermost application. You should configure it with following environment variables :
* `MM_USERNAME`: database username
* `MM_PASSWORD`: database password
* `MM_DBNAME`: database name

If you use a custom PostgreSQL installation, you can configure database host and port with :
* `DB_HOST`: database host address
* `DB_PORT_NUMBER`: database port

If you use a Mattermost configuration file on a different location than the default one (`/mattermost/config/config.json`) :
* `MM_CONFIG`: configuration file location inside the container.

If you choose to use MySQL instead of PostgreSQL, you should set a different datasource and SQL driver :
* `DB_PORT_NUMBER` : `3306`
* `MM_SQLSETTINGS_DRIVERNAME` : `mysql`
* `MM_SQLSETTINGS_DATASOURCE` : `MM_USERNAME:MM_PASSWORD@tcp(DB_HOST:DB_PORT_NUMBER)/MM_DBNAME?charset=utf8mb4,utf8&readTimeout=30s&writeTimeout=30s`
Don't forget to replace all entries (beginning by `MM_` and `DB_`) in `MM_SQLSETTINGS_DATASOURCE` with the real variables values.

#### Volumes

To ensure data persistence the `app` container need to use volumes or bind mounts for several folders inside the container :
- `/mattermost/config`
- `/mattermost/data`
- `/mattermost/logs`
- `/mattermost/plugins`
- `/mattermost/client/plugins`

Because the Mattermost application is running with a non-root user all those folders should have access rights for this user. If you use bind mounts, you should first create the appropriate folders on your host server:
```
mkdir -p /docker/volumes/mattermost/app/{data,logs,config,plugins}
chown -R 2000:2000 /docker/volumes/mattermost/app
```

#### Run
Considering this, here is an example of how to run the `app` container :

```
docker run -d --name mattermost-app --net mattermost-net \
-e MM_USERNAME=mmuser -e MM_PASSWORD=mmuser_password -e MM_DBNAME=mattermost \
-v /docker/volumes/mattermost/app/config:/mattermost/config \
-v /docker/volumes/mattermost/app/data:/mattermost/data \
-v /docker/volumes/mattermost/app/logs:/mattermost/logs \
-v /docker/volumes/mattermost/app/plugins:/mattermost/plugins \
-v /docker/volumes/mattermost/app/client-plugins:/mattermost/client/plugins \
-v /etc/localtime:/etc/localtime:ro \
mattermost/mattermost-prod-app
```

### Expose your application

The `app` container serve the Mattermost application on its port `8000`. There are a lot of different ways to expose your server to the outside world : with a reverse-proxy or not, enabling TLS or not (using Let's Encrypt or not), etc. This choice is yours because it depends a lot on your needs and your infrastructure.

Whatever your choise is, you just need to expose the port `8000` of the `app` container. You can do it directly but we recommend to use a reverse proxy (Nginx, Traefik, Caddie, etc.). If you really don't know how to do it, you can have an example of a Traefik deployment by looking to the [`contrib/traefik`](contrib/traefik) folder, or use the [official `nginx` image from Docker Hub](https://hub.docker.com/_/nginx) and configure it following [the Mattermost documentation](https://docs.mattermost.com/install/install-debian-88.html#configuring-nginx-as-a-proxy-for-mattermost-server).

## Update Mattermost to latest version

If you build the Docker images yourself, you need to follow the build process with the new version of the repository. Each Mattermost version is tagged as a [Github release](https://github.com/mattermost/mattermost-docker/releases) that you can use to have stable Docker images.  
If you use images already built from Docker Hub, you need to download the new ones. Each Mattermost version is tagged in Docker Hub images, so you can deploy a specific version (like `mattermost/mattermost-prod-app:6.0.0`).

In both case, build or download the new images on your server. Then restart your containers (`app` and `db`) with the new images. It is important to start your containers with the same parameters (environment variables, volumes, etc.) so we recommend to use a tool like [Docker Compose](https://docs.docker.com/compose/overview/).

**Important note :** Sometimes a breaking changes may be introduced to Docker images. We do our best to reduce the impact and to notify users in Mattermost changelog. You can have a track of all breaking changes, with specific upgrade procedures, by looking to at the [UPGRADE-NOTES.md](UPGRADE-NOTES.md) file.

## Examples and contributions

The [`contrib`](contrib/) folder contains several examples of deployment from community members. You can use them as examples.

- To run behind the Traefik reverse-proxy with TLS, check the [Traefik example](contrib/traefik/README.md).
- To run Mattermost on a Swarm cluster you can start with the [docker stack example](contrib/swarm/README.md).
- To run Mattermost on Kubernetes you can start with the [manifest examples in the kubernetes folder](contrib/kubernetes/README.md).
- You can push Mattermost to Cloud Foundry using [a manifest example](contrib/cloudfoundry/README.md).
- To install this Docker project on AWS Elastic Beanstalk please see [AWS Elastic Beanstalk Guide](contrib/aws/README.md).

## Known Issues

* Do not modify the Listen Address in Service Settings.
* Rarely `app` container fails to start because of "connection refused" to database. Workaround is to restart the container.
