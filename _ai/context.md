# AI Context for Stick World

## Project Purpose

- Multiplayer stickman game using Godot, with web, iOS, and Pi builds.

## Key Directories

- `game/`: Godot project files.
- `scripts/`: Build and deployment scripts.
- `web/`: Go static file server for web deployment.

## Build Process

- Use `./scripts/build-web.sh [hostname]` to build for web.
- See README.md for more details and platform-specific instructions.

## Deployment Notes

- For local dev, use `./scripts/build-web.sh localhost` and run the generated webserver in `build/`.
- For Pi deployment, use `GOOS=linux GOARCH=arm64 ./scripts/build-web.sh pi44g.local && ./scripts/cp-web.sh pi44g.local`.
- Systemd service templates and instructions are in the README.

## Multiplayer

- World scene uses `MultiplayerSpawner` to replicate nodes.
- Player uses `MultiplayerSynchronizer` for position sync and authority.

## WebRTC

- Signaling server must be running for multiplayer (see README for command).
- `IS_WEB_RTC` in `world.gd` toggles client/server/WebRTC mode.

## Blender & Art

- Art assets and animations are in `art/` and `game/art/`.
- Mixamo and Rigify notes in README.

## Blender Rig Scripts

- The main script for preparing Mixamo (and Rigify) armatures for Godot is `art/blender/scripts/rigify-to-godot.py`.
  - This script modifies a Rigify or Mixamo armature in-place, creating a Godot-friendly TGT (Target) bone collection.
  - It renames, duplicates, and re-parents bones, sets up constraints, and disables deform on original bones.
  - Run this script in Blender with the armature selected before exporting to Godot.
- See the script's docstring for details on usage and features.

## Known Issues

- Update export file list when adding new assets.
- See TODO.md for outstanding tasks.

## Useful Links

- [README.md](../README.md)
- [TODO.md](../TODO.md)
