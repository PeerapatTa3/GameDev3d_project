extends CharacterBody3D

@export var speed : int = 2
@export var hp : int = 15
@export var coin_on_kill : int = 10
@export var kill_point : int = 1

var Path : PathFollow3D

func _ready() -> void:
	Path = get_parent()

func _physics_process(delta):
	Path.set_progress(Path.get_progress() + speed * delta)

func take_damage(damage : int) -> void:
	hp -= damage
	
	if hp <= 0:
		GameStatus.kill += kill_point
		GameStatus.coin += coin_on_kill
		queue_free()
