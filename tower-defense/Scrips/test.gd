extends Node3D

@onready var enemy : PackedScene = preload("res://Mob/ufo.tscn")

var enemy_to_spawn : int = 3
var can_spawn : bool = true


func _process(delta):
	game_maneger()

func game_maneger() -> void:
	if enemy_to_spawn > 0 and can_spawn:
		$SpawnTimer.start()
		
		var tempEnemy = enemy.instantiate()
		$Path.add_child(tempEnemy)
		
		enemy_to_spawn -= 1
		
		can_spawn = false




func _on_spawn_timer_timeout() -> void:
	can_spawn = true
