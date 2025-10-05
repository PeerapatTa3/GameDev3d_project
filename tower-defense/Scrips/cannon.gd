extends StaticBody3D

var bullet : PackedScene = preload("res://scenes/bullet.tscn")
var bullet_damage : int = 5
var current_targets : Array = []
var curr : CharacterBody3D
var can_shoot : bool = true

func _process(delta):
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
	var temp_bullet : CharacterBody3D = bullet.instantiate()
	temp_bullet.target = curr
	temp_bullet.bullet_damage = bullet_damage
	get_node("bulletContainner").add_child(temp_bullet)
	temp_bullet.global_position = $MeshInstance3D/aim.global_position

func choose_target(_current_targets : Array) -> void:
	var temp_array : Array = _current_targets
	var curret_target : CharacterBody3D = null
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
