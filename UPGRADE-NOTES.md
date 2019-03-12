# Upgrade notes

When you upgrade your Mattermost containers, please check at those upgrade notes for some breaking changes.

## Upgrading Mattermost to 6.0+

Starting with Mattermost `6.0` :
- we stopped to support the `web` Docker image (you can find more information about it on [#245](https://github.com/mattermost/mattermost-docker/issues/245))
- we stopped to maintain a "too generic" `docker-compose.yml` file

If you were not using the `web` image and the `docker-compose.yml` file provided in this repository, nothing changed for you.  

If you used the `web` image or the `docker-compose.yml` file, we invite you to setup your own reverse proxy and to write your own Docker Compose file.  
A good starting point is to look at the [Traefik deployment example](contrib/traefik/README.md) that is close to the previous Docker Compose file and support TLS. **Please backup your existing volumes, data and configuration** before the migration, in this example the path to Docker bind mounts changed. Ensure you move all your data (with correct access rights) to the right folders.  
If you don't want to use Traefik, you can also use the [official `nginx` image from Docker Hub](https://hub.docker.com/_/nginx) and configure it following [the Mattermost documentation](https://docs.mattermost.com/install/install-debian-88.html#configuring-nginx-as-a-proxy-for-mattermost-server) (which will result in a similar Docker image than the old `web` image).

## Upgrading Mattermost to 4.9+

Docker images for `4.9.0` release introduce some important changes from [PR #241](https://github.com/mattermost/mattermost-docker/pull/241) to improve production use of Mattermost with Docker.
**There are 2 important changes for existing installations**

One important change is that we don't use `root` user by default to run the Mattermost application. So, as explained on [the README](https://github.com/mattermost/mattermost-docker#start), if you use host mounted volume you have to be sure that files on your host server have the correct UID/GID (by default those values are `2000`). In practice, you should just run following commands :
```
mkdir -p ./volumes/app/mattermost/{data,logs,config,plugins}
chown -R 2000:2000 ./volumes/app/mattermost/
```

The second important change is the port used by Mattermost application container. The default port is now `8000`, and existing installations that use port `80` will not work without a little configuration change. You have to open your Mattermost configuration file (`./volumes/app/mattermost/config/config.json` by default) and change the key `ServiceSettings.ListenAddress` to `:8000`.
Also if you use your own web-server/reverse-proxy you need to change its configuration to reach port `8000` of the Mattermost container.


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
