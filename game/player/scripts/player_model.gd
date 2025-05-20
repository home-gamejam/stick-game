extends Node3D

class_name PlayerModel

@onready var _animation_player = %AnimationPlayer as AnimationPlayer
@onready var _animation_tree = %AnimationTree as AnimationTree

var skeleton: Skeleton3D:
	get:
		return $rig/Skeleton3D

func play_animation(animation: String) -> void:
	match animation:
		"stickman_animations/Idle", "stickman_animations/Walk", "stickman_animations/Run":
			_animation_tree.active = true
			_animation_tree.set("parameters/Movement/blend_position", 0)

		_:
			_animation_tree.active = false
			_animation_player.play(animation)
