extends Node3D


const PLAYER_SCENE = preload("res://main/player.tscn")

@onready var waiting_room: WaitingRoom = %WaitingRoom

var game_started = false

func _ready() -> void:
	var lobby = %SignalLobby

	lobby.player_added.connect(_on_player_added)
	lobby.lobby_sealed.connect(_on_lobby_sealed)


func _on_player_added(pid: int):
	print("[world] _on_player_added: ", pid)
	print("[world] Adding player to waiting list: ", pid)
	waiting_room.add_player(pid)

	if game_started:
		_move_players_to_game();


func _on_lobby_sealed(_lobby_id: int):
	_move_players_to_game()
	game_started = true


func _move_players_to_game():
	%SignalLobby.hide()
	%WaitingRoom.hide()
	%Ground.show()

	for pid in waiting_room.remove_players():
		print("[world] Adding player to scene: ", pid)

		var player = PLAYER_SCENE.instantiate()
		player.name = str(pid)
		var x = randi() % 10
		var z = randi() % 10
		player.position = Vector3(x, 0, z)

		%Players.add_child(player)
