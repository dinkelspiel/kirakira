FROM caddy:latest
RUN apk add --update rebar3 build-base bsd-compat-headers curl nodejs npm inotify-tools
RUN apk add \
  --no-cache \
  --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
  gleam=~1.3
COPY ./frontend /app
COPY ./shared /shared
WORKDIR /app
RUN gleam run -m lustre/dev build app
COPY Caddyfile /etc/caddy/Caddyfile
RUN mkidr /srv
COPY /app/index.html /srv/index.html
COPY /app/priv /srv/priv
