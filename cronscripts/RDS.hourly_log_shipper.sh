#!/bin/bash
# Requires
# RDS_INSTANCE   : RDS instance name
# RDS_AWS_REGION : RDS region (if different to the container)
# RDS_S3_BUCKET  : S3 bucket to ship logs to

if [[ -z "${AWS_DEFAULT_REGION}" ]]; then
  AWS_DEFAULT_REGION=eu-west-1
fi
if [[ -z "${RDS_AWS_REGION}" ]]; then
  RDS_AWS_REGION=$AWS_DEFAULT_REGION
fi
if [[ -z "${RDS_S3_BUCKET}" ]]; then
  RDS_S3_BUCKET="rds-logs.${RDS_INSTANCE}"
fi

offset=900
# "date --date='15 minutes ago'" does not work inside a docker container, so switching to awk
# date +%s | awk '{print strftime("%Y",$1 -900)}'
YEAR=$( date +%s | awk -v offset="${offset}" '{print strftime("%Y", $1 - offset )}')
MONTH=$(date +%s | awk -v offset="${offset}" '{print strftime("%m", $1 - offset )}')
DAY=$(  date +%s | awk -v offset="${offset}" '{print strftime("%d", $1 - offset )}')
HOUR=$( date +%s | awk -v offset="${offset}" '{print strftime("%H", $1 - offset )}')

LOG_FILE="${RDS_INSTANCE}.${YEAR}-${MONTH}-${DAY}-${HOUR}"
DIR_STRUCTURE="${YEAR}/${MONTH}/${DAY}"

mkdir -p "${DIR_STRUCTURE}"
AWS_DEFAULT_REGION=${RDS_AWS_REGION} aws rds download-db-log-file-portion \
  --db-instance-identifier ${RDS_INSTANCE} \
  --log-file-name error/${LOG_FILE} \
  --starting-token 0 \
  --output text > ${DIR_STRUCTURE}/${LOG_FILE}.log
aws s3 cp ${YEAR} s3://${RDS_S3_BUCKET}/hourly-${YEAR} --recursive
rm -rf "${YEAR}"
