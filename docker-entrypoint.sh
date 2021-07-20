#!/usr/bin/env sh

set -e

if [ ! -f "/home/azion/.aws/credentials" ]; then
    aws configure
fi

if [ ! -s "/home/azion/.aws/identity.json" ]; then
    aws sts get-caller-identity > "/home/azion/.aws/identity.json"
fi

SESSION_EXPIRATION=0
if [ -s "/home/azion/.aws/session.json" ]; then
    EXPIRATION=`jq --raw-output .Credentials.Expiration "/home/azion/.aws/session.json"`
    SESSION_EXPIRATION=`date -d"$EXPIRATION" +%s`
fi

CURRENT_DATETIME=`date +%s`

if [ "$SESSION_EXPIRATION" -le "$CURRENT_DATETIME" ]; then
    read -p "MFA Token Code: " AWS_TOKEN_CODE
    AWS_SERIAL_NUMBER=`jq --raw-output .Arn "/home/azion/.aws/identity.json" | sed 's/:user/:mfa/'`
    aws sts get-session-token --serial-number "$AWS_SERIAL_NUMBER" --token-code "$AWS_TOKEN_CODE" > "/home/azion/.aws/session.json"
fi

export AWS_ACCESS_KEY_ID=`jq --raw-output .Credentials.AccessKeyId "/home/azion/.aws/session.json"`
export AWS_SECRET_ACCESS_KEY=`jq --raw-output .Credentials.SecretAccessKey "/home/azion/.aws/session.json"`
export AWS_SESSION_TOKEN=`jq --raw-output .Credentials.SessionToken "/home/azion/.aws/session.json"`

aws $*
