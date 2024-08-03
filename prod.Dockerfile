FROM alpine:latest
RUN apk add \
    --no-cache \
    --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
    gleam=~1.3
RUN apk add rebar3 build-base bsd-compat-headers curl nodejs npm inotify-tools mysql-client
COPY . /app
WORKDIR /app
CMD ["sh", "./run-prod.sh"]
