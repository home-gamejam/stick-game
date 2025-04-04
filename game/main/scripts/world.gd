extends Node3D


const PLAYER_SCENE = preload("res://main/player.tscn")

# Set this to determine client / server or WebRTC lobby
var IS_WEB_RTC = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var lobby_path = "res://signal_ws/signal_ws_lobby.tscn" if IS_WEB_RTC else "res://client/lobby.tscn"
	var lobby = load(lobby_path).instantiate()
	add_child(lobby)

	lobby.player_added.connect(_on_player_added)


func _on_player_added(pid: int):
	print("[world] _on_player_added: ", pid)
	var player = PLAYER_SCENE.instantiate()
	player.name = str(pid)
	var x = randi() % 10
	var z = randi() % 10
	player.position = Vector3(x, 0, z)
	add_child(player)
