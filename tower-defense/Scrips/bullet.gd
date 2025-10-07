extends CharacterBody3D
class_name Bullet

var target : CharacterBody3D
@export var speed : int = 20
var bullet_damage : int 
@export var area : Area3D

func _ready() -> void:
	if area:
		area.body_entered.connect(_on_collusion_body_entered)

func _physics_process(delta):
	if is_instance_valid(target):
		var dir = global_position.direction_to(target.global_position)
		velocity = dir * speed
		look_at(target.global_position)
		rotate_y(deg_to_rad(180))
		
		move_and_slide()
	else:
		queue_free()

func _on_collusion_body_entered(body: Node3D) -> void:
	if body.is_in_group("Enemy"):
		body.take_damage(bullet_damage)
		queue_free()
