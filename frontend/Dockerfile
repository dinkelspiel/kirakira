FROM ghcr.io/gleam-lang/gleam:v1.2.1-erlang-alpine
RUN apk add --update nodejs npm inotify-tools
COPY ./frontend /app
COPY ./shared /shared
WORKDIR /app
CMD ["gleam", "run", "-m", "lustre/dev", "start", "--proxy-from=/api", "--proxy-to=http://backend:8000/"]
