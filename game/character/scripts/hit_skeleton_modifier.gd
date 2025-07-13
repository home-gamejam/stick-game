class_name HitSkeletonModifier extends SkeletonModifier3D

var delta: float = 0.0
var elapsed: float = 0.0
var last_time_check: float = 0.0

var force: Vector3
var target_transforms: Dictionary[int, Transform3D] = {}
var current_transforms: Dictionary[int, Transform3D] = {}
var skeleton: Skeleton3D

func _process_modification() -> void:
	skeleton = get_skeleton()

	if self.influence == 0.0 or not skeleton or target_transforms.is_empty():
		# reset timers
		delta = 0.0
		elapsed = 0.0
		last_time_check = 0.0
		return

	update_times()
	update_transforms()
	# update_bones()

func trigger(bone_name: String, force_: Vector3) -> void:
	# This seems to work sometimes but behavior is a bit inconsistent. Idea is
	# to apply the force in the local space of the skeleton. There may be other
	# reasons for the inconsistency. TBD
	force = skeleton.global_transform.inverse() * force_

	# Initialize timers
	if last_time_check == 0.0:
		last_time_check = Time.get_unix_time_from_system()

	var bone_idx = skeleton.find_bone(bone_name)
	if bone_idx == -1:
		return

	var start: Transform3D = skeleton.get_bone_global_pose(bone_idx)

	# If we already have a current transform, we are in the middle of handling a
	# previous hit, so don't overwrite. If not, start with the rest transform.
	if not current_transforms.has(bone_idx):
		current_transforms.set(bone_idx, start)

	target_transforms.set(bone_idx, start.translated(force * .01))

func update_times():
	var now = Time.get_unix_time_from_system()
	delta = now - last_time_check
	elapsed += delta
	last_time_check = now
	# print("elapsed: ", elapsed, ", delta: ", delta)

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
			var start: Transform3D = skeleton.get_bone_global_pose(bone_idx)

			if current_transforms.get(bone_idx) == start:
				# clear transforms if we have already reached the rest position
				current_transforms.erase(bone_idx)
				target_transforms.erase(bone_idx)
			else:
				# set target back to rest transform
				target_transforms.set(bone_idx, start)

		DebugOverlay.show_text(
			"\n".join([str(force.x) + ", " + str(force.z), current.origin, target.origin])
		)

		var pose = current_transforms.get(bone_idx)
		if pose:
			skeleton.set_bone_global_pose(bone_idx, pose)
