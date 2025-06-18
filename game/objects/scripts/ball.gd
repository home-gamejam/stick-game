class_name Ball extends RigidBody3D

const BALL = preload("res://objects/ball.tscn")
const SPAWN_HEIGHT = 1.5
const SPAWN_OFFSET = .5

static func spawn(source: Node3D) -> Ball:
	var ball: Ball = BALL.instantiate()

	var forward: Vector3 = source.global_transform.basis.z
	ball.global_transform.origin = source.global_transform.origin + forward * SPAWN_OFFSET + Vector3.UP * SPAWN_HEIGHT

	var speed = 20.0
	ball.linear_velocity = forward * speed

	return ball
