# Input for multiplayer with netfox
extends BaseNetInput

class_name PlayerNetInput

var input_dir: Vector2 = Vector2.ZERO
var is_jumping: bool = false
var is_running: bool = false

func _gather():
  input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
  is_jumping = Input.is_action_just_pressed("ui_accept")
  is_running = Input.is_action_pressed("run")
