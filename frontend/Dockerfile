FROM ghcr.io/gleam-lang/gleam:v1.2.1-erlang-alpine
RUN apk add --update nodejs npm inotify-tools
COPY . /app
WORKDIR /app
CMD ["gleam", "run", "-m", "lustre/dev", "start"]
