# Require host arg. If it doesn't exist exit with error code
if [ -z "$1" ]; then
  echo "Please provide a host argument"
  exit 1
fi

host=$1

./build/build-web.sh $host
cp certs/$host.* build/

echo "Building Web..."
/Applications/Godot-v4.3.app/Contents/MacOS/Godot \
 --headless \
 --export-release "Web" build/web/index.html


echo "Copying web to $host..."
scp -r ./build/web/* $USER@$host:~/stick-world-web/web
scp ./build/$host.* $USER@$host:~/stick-world-web/

echo "Building Pi..."
/Applications/Godot-v4.3.app/Contents/MacOS/Godot \
 --headless \
 --export-release "Raspberry Pi" build/pi/pi.arm64

echo "Copying to $host..."
scp ./build/pi/pi.arm64 $USER@$host:~/stick-world/

