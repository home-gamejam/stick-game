# Require host arg. If it doesn't exist exit with error code
if [ -z "$1" ]; then
  echo "Please provide a host argument"
  exit 1
fi

echo "Building Web..."
/Applications/Godot-v4.3.app/Contents/MacOS/Godot \
 --headless \
 --export-release "Web" build/web/index.html

host=$1

echo "Building web server..."
# Set these 2 env variables to build for arm64
# GOOS=linux GOARCH=arm64
go build -ldflags "-X main.certBaseName=$host" -o build/$host.webserver web/main.go