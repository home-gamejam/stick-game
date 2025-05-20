@tool
extends EditorScenePostImport

func _post_import(scene):
	for node in scene.get_children():
		if node is AnimationPlayer:
			var anim_lib = node.get_animation_library("")
			print("[Post import] animation player: ", node.name)
			ResourceSaver.save(anim_lib, "res://resources/" + scene.name + "_animations.tres")

			# Remove the AnimationPlayer from the scene
			# node.get_parent().remove_child(node)
			# node.queue_free()

	return scene
