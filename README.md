# Stick World

## Multiplayer

- World scene has MultiplayerSpawner node. This watches a specific node for anything added and replicates it. Spawn path is set to World where players get added. Auto spawn list inclues Player scene.
- Player has a MultiplayerSynchronizer node that syncs position. Also calls set_multiplayer_authority in \_enter_tree() with its name / pid so that it only controls itself

## Build Script

Builds web server, pi game, and web game
./build/build.sh pi44g.local
