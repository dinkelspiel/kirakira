cd ./client
echo "pub fn get_api_url() { \"http://localhost:1234\" }" > ./src/env.gleam
gleam run -m lustre/dev start --proxy-from=/api --proxy-to=http://localhost:8001/api &
cd ../server
DB_HOST=localhost DB_PASSWORD=kirakira DB_USER=root DB_NAME=kirakira DB_PORT=3306 gleam run && fg
