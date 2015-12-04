Dockerfiles for Mattermost in production

## Requirement

* [docker]
* [docker-compose]

## Howto

### Install SSL certificate

You must install SSL certificate before starting. Put your SSL certificate as
`web/cert/cert.pem` and the private key that has no password as
`web/cert/private/key-no-password.pem`.

If you don't have them you can generate a self-signed SSL certificate.

### (Re)start

1. Run `docker-compose up -d`.
2. Open `https://your.domain:8065` with your web browser.

### Stop

Run `docker-compose stop`.

### Remove the containers

Run `docker-compose stop && docker-compose rm`.

### Remove the data and settings of your mattermost instance

Remove `volumes` directory

## Known Issues

* Do not modify the Listen Address in Service Settings.

## More informations

If you want to know how to use docker-compose, see [the overview
page](https://docs.docker.com/compose).

For the server configurations, see [Production-Ubuntu.md] of mattermost.

[docker]: http://docs.docker.com/engine/installation/
[docker-compose]: https://docs.docker.com/compose/install/
[Production-Ubuntu.md]: https://github.com/mattermost/platform/blob/master/doc/install/Production-Ubuntu.md
