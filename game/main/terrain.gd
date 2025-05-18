@tool
extends Node

class_name Terrain

@export var depth: int = 100
@export var width: int = 100
@export var resolution: int = 1
@export var material: Material
@export var noise: FastNoiseLite

var mesh: MeshInstance3D

func _ready():
	generate()


func generate():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(width, depth)
	plane_mesh.subdivide_depth = depth * resolution
	plane_mesh.subdivide_width = width * resolution
	plane_mesh.material = material

	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)
	var surface_array_mesh = surface_tool.commit()

	var mesh_data_tool = MeshDataTool.new()
	mesh_data_tool.create_from_surface(surface_array_mesh, 0)

	for i in range(mesh_data_tool.get_vertex_count()):
		var vertex = mesh_data_tool.get_vertex(i)
		vertex.y = get_noise_y(vertex.x, vertex.z)
		mesh_data_tool.set_vertex(i, vertex)

	surface_array_mesh.clear_surfaces()
	mesh_data_tool.commit_to_surface(surface_array_mesh)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(surface_array_mesh, 0)
	surface_tool.generate_normals()

	mesh = MeshInstance3D.new()
	mesh.mesh = surface_tool.commit()
	mesh.create_trimesh_collision()
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	#mesh.add_to_group("NavSource")

	add_child(mesh)

func get_noise_y(x: int, z: int) -> float:
	return noise.get_noise_2d(x, z) * 50
