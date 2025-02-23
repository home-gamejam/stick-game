# Require host arg. If it doesn't exist exit with error code
if [ -z "$1" ]; then
  echo "Please provide a host argument"
  exit 1
fi

host=$1

echo "Building..."
/Applications/Godot-v4.3.app/Contents/MacOS/Godot \
 --headless \
 --export-release "Raspberry Pi" build/pi/pi.arm64

echo "Copying to $1..."
scp ./build/pi/pi.arm64 $USER@$1:~/stick-world/
