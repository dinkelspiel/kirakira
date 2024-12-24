# Kirakira

## How to setup a development environment

Install [docker](https://docs.docker.com/) and
[docker compose](https://docs.docker.com/compose/)

and then run

```sh
$ sh setup-env.sh
```

**Note** running setup-env.sh clears your database so it is recommended
to run:

```sh
$ docker-compose up postgres dev -d
```

for all future runs if you want to persist your development data
