FROM caddy:latest
RUN apk add --update rebar3 build-base bsd-compat-headers curl nodejs npm inotify-tools
RUN apk add \
  --no-cache \
  --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
  gleam=~1.3
COPY ./frontend /app
COPY ./shared /shared
WORKDIR /app
RUN gleam clean
RUN sh env.sh https://kirakira.keii.dev
RUN gleam run -m lustre/dev build app
RUN cp /app/Caddyfile /etc/caddy/Caddyfile
RUN cp /app/index.html /srv/index.html
RUN cp /app/priv /srv/priv -r
