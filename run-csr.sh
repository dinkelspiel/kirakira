cd ./client
echo "pub fn get_api_url() { \"http://localhost:1234\" }" > ./src/env.gleam
gleam run -m lustre/dev start --proxy-from=/api --proxy-to=http://localhost:8001/api &
cd ../server
DB_HOST=localhost DB_PASSWORD=kirakira DB_USER=root DB_NAME=kirakira DB_PORT=3306 RESEND_API_KEY=API_KEY_HERE RESEND_EMAIL="kirakira@example.com" gleam run && fg
