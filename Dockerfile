FROM alpine:3.14

RUN apk add --no-cache aws-cli coreutils jq \
    && adduser -u 1000 -g 1000 -D azion \
    && mkdir /home/azion/.aws \
    && chown 1000:1000 /home/azion/.aws

COPY ./docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

USER 1000
