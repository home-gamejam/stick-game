extends Node3D


const PLAYER_SCENE = preload("res://main/player.tscn")
const LOBBY_SCENE = preload("res://main/lobby.tscn")
const LOBBY_WEBRTC_SCENE = preload("res://main/lobby_webrtc_utc.tscn")

# Set this to determine client / server or WebRTC lobby
var IS_WEB_RTC = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var lobby = LOBBY_WEBRTC_SCENE.instantiate() if IS_WEB_RTC else LOBBY_SCENE.instantiate()
	add_child(lobby)

	lobby.player_added.connect(_on_player_added)


func _on_player_added(pid: int):
	print("_on_player_added: ", pid)
	var player = PLAYER_SCENE.instantiate()
	player.name = str(pid)
	var x = randi() % 10
	var z = randi() % 10
	player.position = Vector3(x, 0, z)
	add_child(player)
