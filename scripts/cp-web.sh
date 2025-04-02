# Require host arg. If it doesn't exist exit with error code
if [ -z "$1" ]; then
  echo "Please provide a host argument"
  exit 1
fi

host=$1

echo "Copying web build $host..."

# certs + webserver executable to host WASM web build
scp ./build/$host.* $USER@$host:~/stick-world/

# WASM web build
scp ./build/web/* $USER@$host:~/stick-world/web
