FROM alpine:latest
RUN apk add \
    --no-cache \
    --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
    gleam=~1.3
RUN apk add rebar3 build-base bsd-compat-headers curl watchexec
COPY ./ /app
WORKDIR /app
ENV DB_HOST mysql
ENV DB_PASSWORD kirakira
ENV DB_USER root
ENV DB_NAME kirakira
ENV DB_PORT 3306
RUN sh ./run-clean.sh
CMD ["watchexec", "-r", "-e", "gleam", "--", "sh", "run-ssr.sh"]
