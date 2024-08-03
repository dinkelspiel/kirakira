# clean
sh ./run-clean.sh
# run
cd ./client
echo "pub fn get_api_url() { \"${API_URL}\" }" > ./src/env.gleam
gleam run -m lustre/dev build --outdir=../server/priv/static --minify
cd ../server
gleam run
