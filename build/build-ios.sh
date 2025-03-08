echo "Building iOS..."
/Applications/Godot-v4.3.app/Contents/MacOS/Godot \
 --headless \
 --export-debug iOS build/ios/stickworld.ipa

# Phone needs to be connected first (can also use --debug flag)
ios-deploy --bundle build/ios/stickworld.ipa