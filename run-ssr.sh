cd ./client
echo "pub fn get_api_url() { \"http://localhost:8001\" }" > ./src/env.gleam
gleam run -m lustre/dev build --outdir=../server/priv/static --minify
cd ../server
DB_HOST=mysql DB_PASSWORD=kirakira DB_USER=root DB_NAME=kirakira DB_PORT=3306 gleam run
