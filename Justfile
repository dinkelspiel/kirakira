clean:
    cd ./client && gleam clean
    cd ./server && gleam clean
    cd ./shared && gleam clean

env:
    docker-compose up postgres -d
    export PGPASSWORD=kirakira
    docker exec kirakira-postgres-1 dropdb -h localhost -U kirakira -e kirakira
    docker exec kirakira-postgres-1 createdb -h localhost -U kirakira -e kirakira
    docker exec kirakira-postgres-1 rm postgredb.sql
    docker cp ./server/postgredb.sql kirakira-postgres-1:/postgredb.sql
    docker exec kirakira-postgres-1 psql -U kirakira -e kirakira -c "\i /postgredb.sql"
    docker exec kirakira-postgres-1 psql -U kirakira -e kirakira -c "INSERT INTO \"user\"(username, email, password) VALUES('admin', 'mail@example.com', '\$2a\$12\$AyNInFMs4SOjtOGY9MvPcO6bFwKKNXgOMh9CEQbcq.o9cmjtKHtFS'); INSERT INTO user_admin(user_id) VALUES(1);"
    docker-compose up server -d
    echo "You can now access the dev environment on https://localhost:1234"
    echo "Admin Account: username: 'admin', email: 'mail@example.com', password: '12345678'"

dev-no-env: clean
    cd ./client && echo "pub fn get_api_url() { \"http://localhost:8001\" }" > ./src/env.gleam
    cd ./client && gleam run -m lustre/dev build --outdir=../server/priv/static --minify
    cd ./server && gleam run

dev:
    export DB_HOST=localhost
    export DB_PASSWORD=kirakira
    export DB_USER=kirakira
    export DB_NAME=kirakira
    export DB_PORT=3306
    just dev-no-env

prod: clean
    cd ./client && echo "pub fn get_api_url() { \"${API_URL}\" }" > ./src/env.gleam
    cd ./client && gleam run -m lustre/dev build --outdir=../server/priv/static --minify
    cd ./server && gleam run
