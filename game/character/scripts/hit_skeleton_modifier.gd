class_name HitSkeletonModifier extends SkeletonModifier3D

var delta: float = 0.0
var elapsed: float = 0.0
var last_time_check: float = 0.0

var target_transforms: Dictionary[int, Transform3D] = {}
var current_transforms: Dictionary[int, Transform3D] = {}

func _process_modification() -> void:
	if self.influence == 0.0 or not get_skeleton() or target_transforms.is_empty():
		# reset timers
		delta = 0.0
		elapsed = 0.0
		last_time_check = 0.0
		return

	update_times()
	update_transforms()
	update_bones()

func trigger(bone_name: String, force: Vector3) -> void:
	# Initialize timers
	if last_time_check == 0.0:
		last_time_check = Time.get_unix_time_from_system()

	var bone_idx = get_bone_idx(bone_name)
	if bone_idx == -1:
		return

	# If we already have a current transform, we are in the middle of handling a
	# previous hit, so don't overwrite. If not, start with the rest transform.
	if not current_transforms.has(bone_idx):
		var rest = get_bone_rest(bone_idx)
		current_transforms.set(bone_idx, rest)

	var current: Transform3D = current_transforms.get(bone_idx)
	target_transforms.set(bone_idx, current.translated(force))

func update_times():
	var now = Time.get_unix_time_from_system()
	delta = now - last_time_check
	elapsed += delta
	last_time_check = now
	# print("elapsed: ", elapsed, ", delta: ", delta)

func update_bones():
	for bone_idx in target_transforms.keys():
		var pose = current_transforms.get(bone_idx)
		get_skeleton().set_bone_pose(bone_idx, pose)

func update_transforms():
	for bone_idx in target_transforms.keys():
		var current: Transform3D = current_transforms.get(bone_idx)
		var target: Transform3D = target_transforms.get(bone_idx)

		var next: Transform3D = Utils.damp(
			current,
			target,
			0.01,
			delta
		)

		var distance = current.origin.distance_to(target.origin)
		if distance > 0.01:
			print(distance, ", ", delta)
			# print("Updating bone: ", bone_name, " distance: ", distance)
			current_transforms.set(bone_idx, next)
		else:
			current_transforms.set(bone_idx, target)
			var rest: Transform3D = get_bone_rest(bone_idx)

			if current_transforms.get(bone_idx) == rest:
				# clear transforms if we have already reached the rest position
				current_transforms.erase(bone_idx)
				target_transforms.erase(bone_idx)
			else:
				# set target back to rest transform
				target_transforms.set(bone_idx, rest)

func get_bone_idx(bone_name: String) -> int:
	var skeleton = get_skeleton()
	if not skeleton:
		return -1
	return skeleton.find_bone(bone_name)

func get_bone_rest(bone_idx: int) -> Transform3D:
	if bone_idx == -1:
		return Transform3D.IDENTITY

	return get_skeleton().get_bone_rest(bone_idx)