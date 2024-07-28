FROM alpine:latest
RUN apk add \
  --no-cache \
  --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
  gleam=~1.3
RUN apk add rebar3 build-base bsd-compat-headers curl
COPY ./backend /app
COPY ./gmysql /gmysql
COPY ./shared /shared
WORKDIR /app
CMD ["gleam", "run"]
