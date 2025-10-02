extends Node3D

@export var grid_map: GridMap
@export var object_scene: PackedScene

var camera: Camera3D
var debug_cube: MeshInstance3D

func _ready() -> void:
	# Find camera automatically (must be grouped as "main_camera")
	var cameras = get_tree().get_nodes_in_group("main_camera")
	if cameras.size() > 0:
		camera = cameras[0]
	else:
		push_error("No camera found with group 'main_camera'!")

	# Create debug cube
	debug_cube = MeshInstance3D.new()
	debug_cube.mesh = BoxMesh.new()
	debug_cube.mesh.size = Vector3(1, 0.1, 1)
	debug_cube.material_override = StandardMaterial3D.new()
	debug_cube.material_override.albedo_color = Color(1, 0, 0, 0.5)
	add_child(debug_cube)

func _process(_delta: float) -> void:
	if camera == null or grid_map == null:
		return

	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var from: Vector3 = camera.project_ray_origin(mouse_pos)
	var to: Vector3 = from + camera.project_ray_normal(mouse_pos) * 1000.0

	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var result := space_state.intersect_ray(query)

	if result.has("position"):
		print("Hit position:", result.position)
		var hit_pos: Vector3 = result.position

		var cell: Vector3i = grid_map.local_to_map(grid_map.to_local(hit_pos))
		var cell_pos: Vector3 = grid_map.to_global(grid_map.map_to_local(cell))

		# Place cube exactly on surface
		cell_pos.y = _get_tile_surface_y(cell)
		debug_cube.visible = true
		debug_cube.position = cell_pos
	else:
		debug_cube.visible = false
	



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			_place_object_on_grid()

func _place_object_on_grid() -> void:
	if camera == null or grid_map == null:
		return

	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var from: Vector3 = camera.project_ray_origin(mouse_pos)
	var to: Vector3 = from + camera.project_ray_normal(mouse_pos) * 1000.0

	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var result := space_state.intersect_ray(query)

	if result.has("position"):
		var hit_pos: Vector3 = result.position
		var cell: Vector3i = grid_map.local_to_map(grid_map.to_local(hit_pos))
		var cell_pos: Vector3 = grid_map.to_global(grid_map.map_to_local(cell))
		_spawn_object(cell_pos)

func _spawn_object(pos: Vector3) -> void:
	if object_scene == null:
		push_warning("No object scene assigned!")
		return

	var obj: Node3D = object_scene.instantiate()
	obj.position = pos
	add_child(obj)

func _get_tile_surface_y(cell: Vector3i) -> float:
	var local_pos: Vector3 = grid_map.map_to_local(cell)
	return local_pos.y + grid_map.cell_size.y * 0.5
