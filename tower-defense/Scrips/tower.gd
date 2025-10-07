extends StaticBody3D
class_name Tower

# ==============================
# ⚙️ Base Tower Configuration
# ==============================
@export var tower_name : String
@export var bullet: PackedScene = preload("res://scenes/bullet/bullet.tscn")
@export var bullet_damage: int = 5
@export var upgrade_cost: int = 50
@export var upgrade_damage_bonus: int = 5
@export var upgrade_level: int = 1
@export var max_upgrade_level: int = 3
@export var attack_range: Area3D
@export var upgrade_range_bonus : float = 0.2
@export var attack_speed : float = 1
@export var upgrade_speed_bonus : float = 0.1
@export var tower_pic : Texture
@export var timer : Timer
var placed_cell : Vector3i

# ==============================
# 🧠 Target Priority
# ==============================
enum TargetPriority { FIRST, LAST, STRONGEST, CLOSEST }
@export var target_priority: TargetPriority = TargetPriority.FIRST

# Debug
@export var debug_draw: bool = true

# ==============================
# 🔢 Runtime Variables
# ==============================
var current_targets: Array = []
var curr: CharacterBody3D
var can_shoot: bool = true
var attack_shape : SphereShape3D

# Debug mesh
@onready var debug_mesh: MeshInstance3D = null

# ==============================
# 🚀 Ready
# ==============================
func _ready() -> void:
	add_to_group("Tower")
	_setup_sphere_attack()
	_create_debug_mesh()
	attack_range.body_entered.connect(_on_mob_detector_body_entered)
	attack_range.body_exited.connect(_on_mob_detector_body_exited)
	timer.timeout.connect(_on_shooting_cool_down_timeout)
	timer.wait_time = attack_speed
	if debug_draw:
		_update_debug_mesh()

# ==============================
# ⚙️ Sphere Setup
# ==============================
func _setup_sphere_attack():
	if attack_range and attack_range.has_node("CollisionShape3D"):
		var collision = attack_range.get_node("CollisionShape3D") as CollisionShape3D
		if collision.shape is SphereShape3D:
			attack_shape = collision.shape.duplicate() as SphereShape3D
			collision.shape = attack_shape
		else:
			push_warning("⚠️ Attack range shape is not a SphereShape3D!")
	else:
		push_warning("⚠️ No CollisionShape3D found in attack_range Area3D")

# ==============================
# 🔄 Process Loop
# ==============================
func _process(_delta):
	if is_instance_valid(curr):
		$MeshInstance3D.look_at(curr.global_position)
		$MeshInstance3D.rotate_y(deg_to_rad(180))
		if can_shoot:
			shoot()
			can_shoot = false
			$ShootingCoolDown.start()
	else:
		for i in get_node("bulletContainner").get_child_count():
			get_node("bulletContainner").get_child(i).queue_free()

# ==============================
# 🎯 Shooting
# ==============================
func shoot() -> void:
	_shoot_bullet(curr)

func _shoot_bullet(target: CharacterBody3D):
	if not is_instance_valid(target):
		return
	var temp_bullet: CharacterBody3D = bullet.instantiate()
	temp_bullet.target = target
	temp_bullet.bullet_damage = bullet_damage
	get_node("bulletContainner").add_child(temp_bullet)
	temp_bullet.global_position = $MeshInstance3D/aim.global_position

# ==============================
# 🎯 Target Selection
# ==============================
func choose_target(_current_targets: Array) -> void:
	if _current_targets.is_empty():
		curr = null
		return

	match target_priority:
		TargetPriority.FIRST:
			curr = _get_target_by_progress(true)
		TargetPriority.LAST:
			curr = _get_target_by_progress(false)
		TargetPriority.STRONGEST:
			curr = _get_target_by_health(true)
		TargetPriority.CLOSEST:
			curr = _get_target_by_distance()

func _get_target_by_progress(is_first: bool) -> CharacterBody3D:
	var best = null
	for t in current_targets:
		if not is_instance_valid(t):
			continue
		if best == null:
			best = t
		else:
			var t_prog = t.get_parent().get_progress()
			var b_prog = best.get_parent().get_progress()
			if is_first and t_prog > b_prog:
				best = t
			elif not is_first and t_prog < b_prog:
				best = t
	return best

func _get_target_by_health(is_strongest: bool) -> CharacterBody3D:
	var best = null
	for t in current_targets:
		if not is_instance_valid(t):
			continue
		if best == null:
			best = t
		else:
			var t_hp = t.hp
			var b_hp = best.hp
			if is_strongest and t_hp > b_hp:
				best = t
			elif not is_strongest and t_hp < b_hp:
				best = t
	return best

func _get_target_by_distance() -> CharacterBody3D:
	var best = null
	var best_dist = INF
	for t in current_targets:
		if not is_instance_valid(t):
			continue
		var dist = global_position.distance_to(t.global_position)
		if dist < best_dist:
			best_dist = dist
			best = t
	return best

# ==============================
# 🧱 Enemy Detection
# ==============================
func _on_mob_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group("Enemy"):
		current_targets.append(body)
		choose_target(current_targets)

func _on_mob_detector_body_exited(body: Node3D) -> void:
	if body.is_in_group("Enemy"):
		current_targets.erase(body)
		choose_target(current_targets)

func _on_shooting_cool_down_timeout() -> void:
	can_shoot = true

# ==============================
# 🧠 Upgrade System
# ==============================
func _input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_on_tower_clicked()

func _on_tower_clicked():
	print("Upgrade Tower")
	if upgrade_level >= max_upgrade_level:
		print("Tower is already max level!")
		return
	if GameStatus.coin < upgrade_cost:
		print("Not enough coin")
		return

	GameStatus.coin -= upgrade_cost
	upgrade_level += 1
	bullet_damage += upgrade_damage_bonus
	attack_speed -= upgrade_speed_bonus
	timer.wait_time = attack_speed
	
	if attack_shape:
		attack_shape.radius += upgrade_range_bonus
	
	_update_debug_mesh()
	print("🔼 Tower upgraded to level %d! New damage: %d" % [upgrade_level, bullet_damage])
	$".".scale *= 1.2

# ======================
# 🧠 Debug Drawing Section (solid SPHERE only)
# ======================
func _create_debug_mesh():
	if debug_mesh:
		return
	debug_mesh = MeshInstance3D.new()
	debug_mesh.name = "DebugRange"

	debug_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0, 1, 0, 0.2)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.flags_unshaded = true
	mat.flags_transparent = true
	debug_mesh.material_override = mat
	add_child(debug_mesh)
	_update_debug_mesh()

func _update_debug_mesh():
	if not debug_mesh:
		return

	var radius: float = 1.0  # fallback radius
	if attack_shape and attack_shape is SphereShape3D:
		radius = attack_shape.radius

	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = radius
	sphere_mesh.height = radius * 2
	sphere_mesh.radial_segments = 32
	sphere_mesh.rings = 16

	debug_mesh.mesh = sphere_mesh
