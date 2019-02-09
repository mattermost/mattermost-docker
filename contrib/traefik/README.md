# Deployment behind Traefik

To expose your Mattermost server you can use the [Traefik](https://traefik.io/) reverse-proxy. It is designed for Docker environment and allow automatic Let's Encrypt certificate management.  

Here is a Docker Compose file example to deploy Mattermost behind Traefik.

## Configuration

### Environment variables

First you need to configure environment variables for the `app` and `db` container, as describe in the README of this project :
- `POSTGRES_USER`
- `POSTGRES_PASSWORD`
- `POSTGRES_DB`
- `MM_USERNAME`
- `MM_PASSWORD`
- `MM_DBNAME`

### Traefik configuration

To enable Traefik and Let's Encrypt, you need to change 2 default values inside the `docker-compose.yml` file :
- Change the line `- "traefik.frontend.rule=Host:my.mattermost.tld"` with the full domain of your Mattermost instance instead of `my.mattermost.tld`
- Change the ACME email (`--acme.email='my@email.tld'`) with the email of your instance's administrator.

## Run

In order to communicate, all your containers should be in the same Docker Network. To do this, you just need to create one manually on your server with :
```
docker network create mattermost-net
```

Then use Docker Compose to start your containers : `docker-compose up -d`.
