# Stick World

## Dev

In world.gd, set `IS_WEB_RTC` to determine client / server or WebRTC

### Dev WebRTC

Run signaling server
./scripts/signal_server_ws.sh
./scripts/signal_server_udp.sh

Build or run the game

### Build iOS

Need to connect phone first
./scripts/build-ios.sh

### Web Build + Html Server

> TODO: support for WebRTC over websockets

Build godot project + golang static file server
./scripts/build-web.sh [hostname]

Run the server
./build/[hostname].webserver

#### Build Web and Deploy to Pi

GOOS=linux GOARCH=arm64 \
 ./scripts/build-web.sh pi44g.local && \
 ./scripts/cp-web.sh pi44g.local

### Build WS Signal Server to Pi

./scripts/build-pi-signal-ws-server.sh pi44g.local

### Build Pi

./scripts/build-pi.sh [pihostname]

## Multiplayer

- World scene has MultiplayerSpawner node. This watches a specific node for anything added and replicates it. Spawn path is set to World where players get added. Auto spawn list inclues Player scene.
- Player has a MultiplayerSynchronizer node that syncs position. Also calls set_multiplayer_authority in \_enter_tree() with its name / pid so that it only controls itself
