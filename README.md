# Kirakira

## How to setup a development environment

### Using Docker

Install [docker](https://docs.docker.com/) and
[docker compose](https://docs.docker.com/compose/)

and then run

```sh
$ sh setup-dev.env.sh
```

> Note running setup-dev-env.sh clears your database so it is recommended
> to run:

```sh
$ docker-compose up mysql server client -d
```

for all future runs if you want to persist your development data

### Uncontainzerized (without docker)

Install [gleam](https://gleam.run/getting-started/install.html) and
[mysql](https://dev.mysql.com/doc/refman/8.0/en/installing.html) or use
[hosted mysql](https://planetscale.com/)

```sh
cd client
gleam run -m lustre/dev start --proxy-from=/api --proxy-to=http://localhost:8001/api
cd ../server
DB_HOST=localhost DB_PASSWORD=kirakira DB_USER=root DB_NAME=kirakira DB_PORT=3306 gleam run
```

> Note this does require you to have a mysql server running on localhost,
> or change the env vars to a hosted instance

## SSR Builds

```sh
cd ./client
gleam run -m lustre/dev build --outdir=../server/priv/static --minify
cd ../server
DB_HOST=localhost DB_PASSWORD=kirakira DB_USER=root DB_NAME=kirakira DB_PORT=3306 gleam run
```

> Note make sure your `client/src/env.gleam` is set to `http://localhost:8001`
