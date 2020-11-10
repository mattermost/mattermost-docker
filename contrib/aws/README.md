## Installation on AWS Elastic Beanstalk

### Requirement

* [The EB CLI](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3.html)

### Install

Make the changes in the config file to reflect your needs (app/mattermost/config/config.json)

```
eb init
eb create prod
eb open prod
```

### Note
You must chmod the config.json file, then compress the whole folder starting form mattemost-docker/contrib/aws/* and then upload the .zip file to elastic beanstalk. 
