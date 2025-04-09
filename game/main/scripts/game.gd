extends Node3D


const PLAYER_SCENE = preload("res://main/player.tscn")

@onready var signal_lobby = %SignalLobby
@onready var waiting_room: WaitingRoom = %WaitingRoom
@onready var world: World = %World

var game_started = false

func _ready() -> void:
	var lobby = %SignalLobby

	lobby.player_added.connect(_on_player_added)
	lobby.lobby_sealed.connect(_on_lobby_sealed)


func _on_player_added(pid: int):
	print("[game] _on_player_added: ", pid)
	print("[game] Adding player to waiting list: ", pid)
	waiting_room.add_player(pid)

	if game_started:
		_move_players_to_game();


func _on_lobby_sealed(_lobby_id: int):
	_move_players_to_game()
	game_started = true


func _move_players_to_game():
	signal_lobby.hide()
	waiting_room.hide()
	world.show()

	for pid in waiting_room.remove_players():
		world.add_player(pid)
