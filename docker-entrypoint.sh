#!/usr/bin/env sh

FILENAME_CREDENTIALS="/home/azion/.aws/credentials"
FILENAME_IDENTITY="/home/azion/.aws/identity.json"
FILENAME_SESSION="/home/azion/.aws/session.json"

set -e

if [ ! -f "$FILENAME_CREDENTIALS" ]; then
    aws configure
fi

if [ ! -s "$FILENAME_IDENTITY" ]; then
    aws sts get-caller-identity > "$FILENAME_IDENTITY"
fi

SESSION_EXPIRATION=0
if [ -s "$FILENAME_SESSION" ]; then
    EXPIRATION=`jq --raw-output .Credentials.Expiration "$FILENAME_SESSION"`
    SESSION_EXPIRATION=`date -d"$EXPIRATION" +%s`
fi

CURRENT_DATETIME=`date +%s`

if [ "$SESSION_EXPIRATION" -le "$CURRENT_DATETIME" ]; then
    read -p "MFA Token Code: " AWS_TOKEN_CODE
    AWS_SERIAL_NUMBER=`jq --raw-output .Arn "$FILENAME_IDENTITY" | sed 's/:user/:mfa/'`
    aws sts get-session-token --serial-number "$AWS_SERIAL_NUMBER" --token-code "$AWS_TOKEN_CODE" > "$FILENAME_SESSION"
fi

export AWS_ACCESS_KEY_ID=`jq --raw-output .Credentials.AccessKeyId "$FILENAME_SESSION"`
export AWS_SECRET_ACCESS_KEY=`jq --raw-output .Credentials.SecretAccessKey "$FILENAME_SESSION"`
export AWS_SESSION_TOKEN=`jq --raw-output .Credentials.SessionToken "$FILENAME_SESSION"`

aws $*
