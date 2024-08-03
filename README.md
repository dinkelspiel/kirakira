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
$ docker-compose up mysql server -d
```

for all future runs if you want to persist your development data

### Uncontainzerized (without docker)

Install [gleam](https://gleam.run/getting-started/install.html) and
[mysql](https://dev.mysql.com/doc/refman/8.0/en/installing.html) or use
[hosted mysql](https://planetscale.com/)

```sh
sh ./run-csr.sh
# or
sh ./run-ssr.sh
```

> Note this does require you to have a mysql server running on localhost,
> or change the env vars to a hosted instance

## Notes

- `lustre_dev_tools` is a temporary vendor, to be removed on next release of
  the package to hex
