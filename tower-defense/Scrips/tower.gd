extends StaticBody3D
class_name Tower

@export var tower_name : String
@export var bullet: PackedScene = preload("res://scenes/bullet.tscn")
@export var bullet_damage: int = 5
@export var upgrade_cost: int = 50
@export var upgrade_damage_bonus: int = 5
@export var upgrade_level: int = 1
@export var max_upgrade_level: int = 3
@export var attack_range: Area3D
@export var upgrade_range_bonus : float = 0.2

var placed_cell : Vector3i
var current_targets: Array = []
var curr: CharacterBody3D
var can_shoot: bool = true
var attack_shape : SphereShape3D

func _ready() -> void:
	add_to_group("Tower")

	if attack_range and attack_range.has_node("CollisionShape3D"):
		var collision = attack_range.get_node("CollisionShape3D") as CollisionShape3D
		if collision.shape is SphereShape3D:
			# ✅ duplicate the shape to make it unique per tower
			attack_shape = collision.shape.duplicate() as SphereShape3D
			collision.shape = attack_shape
		else:
			push_warning("⚠️ Attack range shape is not a SphereShape3D!")
	else:
		push_warning("⚠️ No CollisionShape3D found in attack_range Area3D")

func _process(_delta):
	if is_instance_valid(curr):
		look_at(curr.global_position)
		rotate_y(deg_to_rad(180))
		if can_shoot:
			shoot()
			can_shoot = false
			$ShootingCoolDown.start()
	else:
		for i in get_node("bulletContainner").get_child_count():
			get_node("bulletContainner").get_child(i).queue_free()

func shoot() -> void:
	var temp_bullet: CharacterBody3D = bullet.instantiate()
	temp_bullet.target = curr
	temp_bullet.bullet_damage = bullet_damage
	get_node("bulletContainner").add_child(temp_bullet)
	temp_bullet.global_position = $MeshInstance3D/aim.global_position

func choose_target(_current_targets: Array) -> void:
	var temp_array: Array = _current_targets
	var curret_target: CharacterBody3D = null
	for i in temp_array:
		if curret_target == null:
			curret_target = i
		else:
			if i.get_parent().get_progress() > curret_target.get_parent().get_progress():
				curret_target = i
	curr = curret_target

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

# ====================
# 🧠 Upgrade section
# ====================

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
	attack_shape.radius += upgrade_range_bonus
	print("🔼 Tower upgraded to level %d! New damage: %d" % [upgrade_level, bullet_damage])

	# Visual feedback
	$MeshInstance3D.scale *= 1.1
