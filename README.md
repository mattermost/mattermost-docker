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
