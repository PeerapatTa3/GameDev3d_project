extends CharacterBody3D

var target : CharacterBody3D
var speed : int = 20
var bullet_damage : int 


func _physics_process(delta):
	if is_instance_valid(target):
		var dir = global_position.direction_to(target.global_position)
		velocity = dir * speed
		look_at(target.global_position)
		
		move_and_slide()
	else:
		queue_free()




func _on_collusion_body_entered(body: Node3D) -> void:
	if body.is_in_group("Enemy"):
		body.take_damage(bullet_damage)
		queue_free()
