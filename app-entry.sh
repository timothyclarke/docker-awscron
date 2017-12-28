#!/bin/bash

if [[ -z "${AWS_DEFAULT_REGION}" ]]; then
  AWS_DEFAULT_REGION=eu-west-1
fi

envsubst < /awscron/templates/aws_config > /root/.aws/config

if [[ ! -z "${AWS_ACCESS_KEY_ID}" ]]&&[[ ! -z "${AWS_SECRET_ACCESS_KEY}" ]]; then
  envsubst < /awscron/templates/aws_credentials > /root/.aws/credentials
fi

rm /awscron/crons

IFS=',' read -r -a cronlist <<< "${CRONS}"
#cronlist=$(echo ${CRONS} | tr "," "\n")
for cron in "${cronlist[@]}"; do
  schedule=$(eval "echo \"\${$(echo SCHEDULE_${cron})}"\")
  command=$(eval "echo \"\${$(echo CMD_${cron})}"\")
  echo "${schedule} /awscron/bin/${command}" >> /awscron/crons
done

echo "" >> /awscron/crons

/usr/bin/crontab /awscron/crons

chmod +x /awscron/bin/*
/usr/sbin/crond -f -m '>/dev/null' -M /usr/local/bin/pipe-dev-null.sh -L /dev/stdout
