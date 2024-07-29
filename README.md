# Kirakira

## How to setup a development environment

// This is very temp but good as a solution if you want to setup a dev env

```
$ docker-compose up mysql -d
```

copy the db.sql from /backend to the container

```
$ docker cp ./backend/db.sql kirakira-mysql-1:/db.sql
```

enter the mysql container and create the database

```
$ docker exec -it kirakira-mysql-1 mysql -u root -p
// it'll prompt you for a password use 'kirakira'
mysql $ use kirakira;
mysql $ source /db.sql;
mysql $ exit;
$ exit;
```

start the backend

```
$ cd ./backend
// run gleam with the database env
$ DB_HOST=localhost DB_PASSWORD=kirakira DB_USER=root DB_NAME=kirakira DB_PORT=3306 gleam run
```

start the frontend

```
$ cd ./frontend
$ sh env.sh http://localhost:1234
$ sh start.sh
```
