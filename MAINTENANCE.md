# Maintainer Guide 

This file outlines the current maintainer(s) of this open source project and expectations. It also includes credits to past maintainers and the project creator. 

## Project Name 

When reference externally, this project should be called: 

- Multi-node Docker image for Mattermost by the Mattermost open source project

## Maintainer(s)

The following people help to maintain this open source project: 

| Current Maintainer(s)  | Start Date    | 
|:-----------------------|:--------------|
| Pan Luo - @xcompass    | 2015-11-30    |

In case something happens where a maintainer is unable to complete their responsibilies or find a new maintainer, the following sponsoring organization can help find a new maintainer: 

| Sponsoring Organization        | Start Date    | 
|:-------------------------------|:--------------|
| Mattermost Open Source Project | 2015-11-30    |


## Maintainer Guide 

The following is a guide for current, new maintainers and prospective maintainers of this open source project to get started and to understand on-going responsibilities: 

### Getting Started 

The following steps should be completed by a new maintainer 

1. **Add your name** - Create a pull request to add your name, GitHub username and start date to this document. 
2. **Subscribe to mailings** - To be notified of new releases and security updates of Mattermost, subscribe to the [Mattermost Security Update Mailing List](http://mattermost.us11.list-manage.com/subscribe?u=6cdba22349ae374e188e7ab8e&id=3a93eb6929) and the [Mattermost Insiders Newsletter](http://mattermost.us11.list-manage.com/subscribe?u=6cdba22349ae374e188e7ab8e&id=2add1c8034)

## Updating 

When receive a mailing list email about a new security update or major version of Mattermost being released, update the version number of this project by doing the following: 

- Change the [version number](https://github.com/mattermost/mattermost-docker/blob/master/app/Dockerfile#L6) in the **master branch** to pull in the latest Mattermost Team Edition release
- Change the [version number](https://github.com/mattermost/mattermost-docker/blob/team-and-enterprise/app/Dockerfile#L6) in the **the team-and-enterprise branch** to pull in the latest Mattermost Enterprise Edition release

## Issue and Pull Request Review 

Maintainer(s) should periodically review pull requests and issues submitted to provide feedback and to merge pull request changes when the maintainer feels the change would be appropriate. 

## Credits 

PREVIOUS MAINTAINERS 

| Creator                | Start Date    | End Date   |
|:-----------------------|:--------------|:-----------|
| Yi EungJun - @npcode   | 2015-11-30    | 2015-11-30 | 


CREATOR 

| Creator                | Created Date  |
|:-----------------------|:--------------|
| Yi EungJun - @npcode   | 2015-11-30    |

