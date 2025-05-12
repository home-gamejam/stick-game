@tool
extends EditorScenePostImport

func _post_import(scene):
	for node in scene.get_children():
		if node is AnimationPlayer:
			var anim_lib = node.get_animation_library("")
			
			ResourceSaver.save(anim_lib, "res://resources/" + scene.name + "_animations.tres")
	return scene
