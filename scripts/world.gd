extends Node3D


const PLAYER_SCENE = preload("res://scenes/player.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Lobby.player_added.connect(_on_player_added)


func _on_player_added():
	print("_on_player_added")
	var player = PLAYER_SCENE.instantiate()
	add_child(player)
