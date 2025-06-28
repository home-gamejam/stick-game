extends Node3D


const PLAYER_SCENE = preload("res://player/player.tscn")

@onready var signal_lobby = %SignalLobby
@onready var controls = %Controls
@onready var landing = %Landing
@onready var waiting_room: WaitingRoom = %WaitingRoom
@onready var world: World = %World

var game_started = false


func _ready() -> void:
	landing.play_pressed.connect(_on_play_pressed)
	landing.multiplayer_pressed.connect(_on_multiplayer_pressed)

	signal_lobby.hide()
	signal_lobby.player_added.connect(_on_player_added)
	signal_lobby.lobby_sealed.connect(_on_lobby_sealed)


func _on_play_pressed() -> void:
	landing.hide()
	controls.show()
	world.show()
	world.add_player(1)


func _on_multiplayer_pressed() -> void:
	landing.hide()
	signal_lobby.show()
	waiting_room.show()


# When players are added, add them to the waiting room. If game has started,
# move them to the game world.
func _on_player_added(pid: int) -> void:
	print("[game] _on_player_added: ", pid, ", is_authority: ", pid == multiplayer.get_unique_id())
	controls.show()
	waiting_room.add_player(pid)

	if game_started:
		_move_players_to_game();


# Move players to game world when the lobby is sealed and mark the game as
# started.
func _on_lobby_sealed(_lobby_id: int):
	_move_players_to_game()
	game_started = true


# Move players from the waiting room to the game world and toggle visibility of
# UI elements so that game world is visible.
func _move_players_to_game():
	signal_lobby.hide()
	waiting_room.hide()
	world.show()

	for pid in waiting_room.remove_players():
		world.add_player(pid)
