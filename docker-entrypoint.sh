#!/usr/bin/env sh

set -xe

if [ ! -f "/home/azion/.aws/credentials" ]; then
    aws configure
fi

aws $*
