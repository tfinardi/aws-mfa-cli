FROM alpine:3.14

RUN apk add --no-cache aws-cli \
    && adduser -u 1000 -g 1000 -D azion \
    && mkdir /home/azion/.aws \
    && chown 1000:1000 /home/azion/.aws

ENTRYPOINT ["/usr/bin/aws"]

USER 1000

WORKDIR /home/azion
