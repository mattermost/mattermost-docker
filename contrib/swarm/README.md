# Installation using Docker Swarm Mode

The following instructions deploy Mattermost in a production configuration using docker swarm mode on one node.
Running containerized applications on multi-node swarms involves specific data portability and replication handling that are not covered here.

## Requirements

* [docker] (1.12.0+)

## Swarm Mode Installation

First, create mattermost directory structure on the docker hosts:
```
mkdir -p /var/lib/mattermost/{cert,config,data,logs,plugins}
```

Then, fire up the stack in your swarm:
```
docker stack deploy -c contrib/swarm/docker-stack.yml mattermost
```
