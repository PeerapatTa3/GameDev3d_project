extends Node3D

@onready var PathFollow : PackedScene = preload("res://Mob/ufo.tscn")
@onready var Enemy : PackedScene = preload("res://Mob/enemy.tscn")

var enemy_to_spawn : int = 10
var can_spawn : bool = true
@export var placement_ui : Node
@export var placement_manager : Node3D

func _ready() -> void:
	# Make sure UI has the signal defined
	placement_ui.tower_selected.connect(placement_manager.select_tower)

func _process(delta):
	game_maneger()

func game_maneger() -> void:
	if enemy_to_spawn > 0 and can_spawn:
		$SpawnTimer.start()
		
		var temp = PathFollow.instantiate()
		var tempEnemy = Enemy.instantiate()
		$Path.add_child(temp)
		temp.add_child(tempEnemy)
		
		enemy_to_spawn -= 1
		
		can_spawn = false

func _on_spawn_timer_timeout() -> void:
	can_spawn = true
