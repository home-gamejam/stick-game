# Require host arg. If it doesn't exist exit with error code
if [ -z "$1" ]; then
  echo "Please provide a host argument"
  exit 1
fi

host=$1

echo "Building web server..."
GOOS=linux GOARCH=arm64 go build -ldflags "-X main.certBaseName=$host" -o build/$host.webserver web/main.go
