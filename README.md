# Stick World

## Dev

In world.gd, set `IS_WEB_RTC` to determine client / server or WebRTC

### Dev WebRTC

Run signaling server
./server/server.sh

Build or run the game

### Build iOS

Need to connect phone first
./build/build-ios.sh

### Web Build + Html Server

> TODO: support for WebRTC over websockets

Build godot project + golang static file server
./build/build-web.sh [hostname]

Run the server
./build/[hostname].webserver

### Build Pi

./build/build-pi.sh [pihostname]

## Multiplayer

- World scene has MultiplayerSpawner node. This watches a specific node for anything added and replicates it. Spawn path is set to World where players get added. Auto spawn list inclues Player scene.
- Player has a MultiplayerSynchronizer node that syncs position. Also calls set_multiplayer_authority in \_enter_tree() with its name / pid so that it only controls itself
