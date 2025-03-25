# Require host arg. If it doesn't exist exit with error code
if [ -z "$1" ]; then
  echo "Please provide a host argument"
  exit 1
fi

host=$1

echo "Building PI Signal WS Server..."
godot44 \
 --path ./signal-ws-server \
 --headless \
 --export-release "Pi" ../build/pi/signal-ws-server.arm64

echo "Copying to $1..."
scp ./build/pi/signal-ws-server.* $USER@$1:~/stick-world/
