#!/usr/bin/env sh

set -e

if [ ! -f "/home/azion/.aws/credentials" ]; then
    aws configure
fi

if [ ! -f "/home/azion/.aws/identity.json" ]; then
    aws sts get-caller-identity > "/home/azion/.aws/identity.json"
fi

SESSION_EXPIRATION=0
if [ -f "/home/azion/.aws/session.json" ]; then
    EXPIRATION=`jq --raw-output .Credentials.Expiration "/home/azion/.aws/session.json"`
    SESSION_EXPIRATION=`date -d"$EXPIRATION" +%s`
fi

CURRENT_DATETIME=`date +%s`

if [ "$SESSION_EXPIRATION" -le "$CURRENT_DATETIME" ]; then
    read -p "MFA Token Code: " AWS_TOKEN_CODE
    AWS_SERIAL_NUMBER=`jq --raw-output .Arn "/home/azion/.aws/identity.json" | sed 's/:user/:mfa/'`
    aws sts get-session-token --serial-number "$AWS_SERIAL_NUMBER" --token-code "$AWS_TOKEN_CODE" > "/home/azion/.aws/session.json"
fi

aws $*
