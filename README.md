# AWS Cron

## Reason
We need to run cron jobs. This container is to allow that AND to have the AWS CLI tools so we can interact with that API

## Build
### To build
```bash
$ docker build -t awscron:latest .
```

## Usage
The container takes a minimum of 3 environmental variables

`CRONS` is a comma seperated list of cronjob names
For each cronjob there should be the following 2 environmental variables
`SCHEDULE_${cron}` and `CMD_${cron}`

eg
```
CRONS=sample
SCHEDULE_sample='0 * * * *'
CMD_sample='/bin/echo "Hello World"'
```
## AWS
If you want to use AWS tools you can provide the following
`AWS_DEFAULT_REGION`, `AWS_ACCESS_KEY_ID` & `AWS_SECRET_ACCESS_KEY`

