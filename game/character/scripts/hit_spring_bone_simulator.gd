class_name HitSpringBoneSimulator extends SpringBoneSimulator3D

var elapsed: float = 0.0
var timer: float = 0.0

func _ready() -> void:
	set_physics_process(false)

func activate_for(time: float) -> void:
	elapsed = 0.0
	timer = time
	active = true
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	elapsed += delta

	if elapsed >= timer:
		elapsed = 0.0
		timer = 0.0
		active = false
		set_physics_process(false)
		return