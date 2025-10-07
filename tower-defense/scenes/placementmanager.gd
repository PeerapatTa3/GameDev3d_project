extends Node3D
class_name MouseHandler

@export var grid_map: GridMap
@export var tile_thickness: float = 0.25  # thickness of a tile (adjust if needed)
@export var upgrade_ui: Upgrade_UI

# runtime
var camera: Camera3D
var ghost_instance: Node3D = null
var selected_tower_scene: PackedScene = null
var selected_tower_cost: int = 0

# occupied tracking (uses string keys "x_y_z")
var occupied_cells := {}

# player economy

func _ready() -> void:
	# auto-find camera (must be added to group "main_camera")
	var cams = get_tree().get_nodes_in_group("main_camera")
	if cams.size() > 0:
		camera = cams[0]
	else:
		push_error("No camera found in group 'main_camera'")

func _process(_delta: float) -> void:
	if camera == null or grid_map == null:
		return
	if selected_tower_scene == null:
		if ghost_instance:
			ghost_instance.visible = false
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

		# place the ghost on top of the tile surface
		cell_pos.y += tile_thickness * 0.5

		if ghost_instance:
			ghost_instance.position = cell_pos
			ghost_instance.visible = true
			var can_place = _can_place_at(cell) and GameStatus.coin >= selected_tower_cost
			GameStatus.coin >= selected_tower_cost
			_set_ghost_color(can_place)
	else:
		if ghost_instance:
			ghost_instance.visible = false

func _unhandled_input(event: InputEvent) -> void:
	# right click cancels placement
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if selected_tower_scene:
			_cancel_placement()

	# left click places if a tile is highlighted
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if selected_tower_scene and ghost_instance and ghost_instance.visible:
			_place_object_on_grid()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_check_tower_click()

func _place_object_on_grid() -> void:
	if camera == null or grid_map == null:
		return

	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var from: Vector3 = camera.project_ray_origin(mouse_pos)
	var to: Vector3 = from + camera.project_ray_normal(mouse_pos) * 1000.0

	var result := get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
	if not result.has("position"):
		return

	var hit_pos: Vector3 = result.position
	var cell: Vector3i = grid_map.local_to_map(grid_map.to_local(hit_pos))
	var cell_pos: Vector3 = grid_map.to_global(grid_map.map_to_local(cell))
	cell_pos.y += tile_thickness * 0.5

	# checks
	if not _can_place_at(cell):
		print("❌ Cell occupied!")
		return
	if GameStatus.coin < selected_tower_cost:
		print("💸 Not enough money! Need:", selected_tower_cost)
		return

	# spend coin
	GameStatus.coin -= selected_tower_cost
	print("✅ Placed! Remaining money ", GameStatus.coin)

	# spawn the actual tower (placed under the current scene root)
	var tower: Tower = selected_tower_scene.instantiate() as Tower
	tower.position = cell_pos
	tower.placed_cell = cell
	get_tree().current_scene.add_child(tower)
	tower.debug_mesh.visible = false

	# mark occupied
	occupied_cells[_cell_key(cell)] = true

	# (optional) keep placing same tower; to place once only, call _cancel_placement()

func select_tower(scene: PackedScene, cost: int = 50) -> void:
	# called by UI (signal), e.g. placement_ui.tower_selected -> PlacementManager.select_tower
	selected_tower_scene = scene
	selected_tower_cost = cost
	print("Selected tower (cost):", cost)

	# create ghost instance
	if ghost_instance:
		ghost_instance.queue_free()
		ghost_instance = null

	ghost_instance = scene.instantiate() as Node3D
	# add ghost to the same main scene so it's visible and in the same world
	get_tree().current_scene.add_child(ghost_instance)

	# turn it into a non-colliding, transparent preview
	_disable_collisions_recursive(ghost_instance)
	_make_ghost_transparent(ghost_instance)
	ghost_instance.visible = false

func _cancel_placement() -> void:
	selected_tower_scene = null
	selected_tower_cost = 0
	if ghost_instance:
		ghost_instance.visible = false
	print("Placement canceled")

# --- helpers ---

func _cell_key(cell: Vector3i) -> String:
	return str(cell.x) + "_" + str(cell.y) + "_" + str(cell.z)

func _can_place_at(cell: Vector3i) -> bool:
	return not occupied_cells.has(_cell_key(cell))

func _disable_collisions_recursive(node: Node) -> void:
	for child in node.get_children():
		# disable CollisionShape3D nodes
		if child is CollisionShape3D:
			child.disabled = true
		# disable any CollisionObject3D (StaticBody3D / Area3D / etc.)
		if child is CollisionObject3D:
			child.collision_layer = 0
			child.collision_mask = 0
		_disable_collisions_recursive(child)

func _make_ghost_transparent(node: Node) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			var mat := StandardMaterial3D.new()
			mat.albedo_color = Color(0, 1, 0, 0.35) # default greenish; color may be changed later
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			child.material_override = mat
		_make_ghost_transparent(child)

func _set_ghost_color(can_place: bool) -> void:
	var color := Color(0, 1, 0, 0.35) if can_place else Color(1, 0, 0, 0.35)
	_update_ghost_material_color(ghost_instance, color)

func _update_ghost_material_color(node: Node, color: Color) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			if child.material_override:
				child.material_override.albedo_color = color
			else:
				var mat := StandardMaterial3D.new()
				mat.albedo_color = color
				mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				child.material_override = mat
		_update_ghost_material_color(child, color)

func _check_tower_click() -> void:
	var camera := get_tree().get_first_node_in_group("main_camera")
	if camera == null || selected_tower_scene != null:
		return

	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000.0

	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))

	if result.has("collider"):
		var clicked = result.collider
		if clicked.is_in_group("Tower") and upgrade_ui:
			upgrade_ui._upgrade_open(clicked)
