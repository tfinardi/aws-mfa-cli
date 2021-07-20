FROM alpine:3.14

RUN apk add --no-cache aws-cli

ENTRYPOINT ["/usr/bin/aws"]
