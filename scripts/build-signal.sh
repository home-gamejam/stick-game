#!/usr/bin/env bash

# Require host arg. If it doesn't exist exit with error code
if [ -z "$1" ]; then
  echo "Please provide a host argument"
  exit 1
fi

host=$1
server_dir=game/addons/signal_ws/server

# Build for Pi
echo "Building Signal Server..."
pushd $server_dir
GOOS=linux GOARCH=arm64 scripts/build.sh
popd

# Signal server executable
echo "Copying signal server to $host..."
scp $server_dir/build/signalserver $USER@$host:~/signal-ws/

# certs
echo "Copying certs to $host..."
scp ./certs/$host.crt $USER@$host:~/signal-ws/
scp ./certs/$host.key $USER@$host:~/signal-ws/