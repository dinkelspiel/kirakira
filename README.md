# Kirakira

## How to setup a development environment

Install [docker](https://docs.docker.com/) and [docker compose](https://docs.docker.com/compose/)

and then run

```sh
$ sh setup-dev.env.sh
```

**NOTE:** Running setup-dev-env.sh clears your database so it is recommended to run

```sh
$ docker-compose up mysql backend frontend -d
```

for all future runs if you want to persist your development data
