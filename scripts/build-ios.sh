#!/bin/bash
set -e

echo "Building iOS..."
godot44 \
 --path ./game \
 --headless \
 --export-debug iOS ../build/ios/stickworld.ipa

# Phone needs to be connected first (can also use --debug flag)
ios-deploy --bundle build/ios/stickworld.ipa