@tool
extends EditorScenePostImport

func _post_import(scene: Node) -> Object:
	# Create a new MeshLibrary resource
	var mesh_library := MeshLibrary.new()
	var mesh_count := 0

	# Recursively collect all MeshInstance3D nodes
	for node in scene.get_children():
		if node is MeshInstance3D:
			var mesh: Mesh = node.mesh
			if mesh:
				mesh_library.create_item(mesh_count)
				mesh_library.set_item_name(mesh_count, node.name)
				mesh_library.set_item_mesh(mesh_count, mesh)
				mesh_count += 1

	# Save the MeshLibrary if any meshes were found
	if mesh_count > 0:
		var glb_path = get_source_file()
		var base_name = glb_path.get_file().get_basename().replace("-", "_")
		var library_dir = "res://resources/mesh_libraries/"
		var library_path = library_dir + base_name + ".tres"
		DirAccess.make_dir_recursive_absolute(library_dir)
		ResourceSaver.save(mesh_library, library_path, ResourceSaver.FLAG_COMPRESS)
		print("MeshLibrary saved to: ", library_path)

	return scene
