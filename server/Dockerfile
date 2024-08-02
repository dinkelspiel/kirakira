FROM alpine:latest
RUN apk add \
    --no-cache \
    --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
    gleam=~1.3
RUN apk add rebar3 build-base bsd-compat-headers curl
COPY ./server /app
COPY ./shared /shared
COPY ./client /client
WORKDIR /client
RUN gleam clean
RUN sh env.sh https://kirakira.keii.dev
WORKDIR /app
CMD ["gleam", "run"]
