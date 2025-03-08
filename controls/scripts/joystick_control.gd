extends Control

@export var auto_center = true
signal stick_position_set(position: Vector2)

var is_active: Dictionary = {}
var local_center: Vector2

func _ready():
	local_center = size / 2

func position_to_action(value: float, op: String, action: String):
	if op == "lt" and value < 0:
		Input.action_press(action, -value / local_center.x)
	elif op == "gt" and value > 0:
		Input.action_press(action, value / local_center.x)
	elif Input.is_action_pressed(action):
		Input.action_release(action)

func set_stick_position(pos: Vector2):
	$Stick.position = pos

	stick_position_set.emit(pos)

	position_to_action(pos.x, "lt", "ui_left")
	position_to_action(pos.x, "gt", "ui_right")
	position_to_action(pos.y, "lt", "ui_up")
	position_to_action(pos.y, "gt", "ui_down")

func _input(event):
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if event is InputEventScreenTouch and not event.is_pressed():
			if is_active.has(event.index) and is_active[event.index]:
				is_active[event.index] = false
				if auto_center:
					set_stick_position(Vector2.ZERO)
				return

		var global_center = global_position + local_center
		var direction = event.position - global_center;
		var is_in_bounds = direction.length() <= local_center.x

		if event is InputEventScreenTouch:
			is_active[event.index] = is_in_bounds

		if is_active[event.index]:
			if is_in_bounds:
				set_stick_position(direction)
			elif event is InputEventScreenDrag:
				set_stick_position(direction.normalized() * local_center.x)
