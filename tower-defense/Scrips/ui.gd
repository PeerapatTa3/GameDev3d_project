extends Node

signal tower_selected(scene: PackedScene, cost: int)

@onready var coin = $CanvasLayer/coin
@onready var kill = $CanvasLayer/Kill
@onready var wave = $CanvasLayer/wave
@onready var enemy = $CanvasLayer/Enemy

func _ready():
	
	tower_selected.connect(func(scene, cost):
		print("UI emitted tower:", scene, "cost:", cost))

func _on_texture_button_pressed() -> void:
		tower_selected.emit(preload("res://scenes/tower/cannon.tscn"), 50)

func _process(delta: float) -> void:
	coin.text = str(GameStatus.coin)
	$CanvasLayer/Kill.text = "Kill : " + str(GameStatus.kills)
	$CanvasLayer/Enemy.text = "Enemy : " + str(GameStatus.enemies_remaining)
	$CanvasLayer/wave.text = "Wave " + str(GameStatus.wave)

func _on_coin_pressed() -> void:
	GameStatus.coin += 100


func _on_texture_button_2_pressed() -> void:
	tower_selected.emit(preload("res://scenes/tower/turret.tscn"), 100)


func _on_setting_pressed() -> void:
	var current_scene = get_tree().current_scene
	get_tree().set_meta("previous_scene_path", current_scene.scene_file_path)
	get_tree().change_scene_to_file("res://scenes/setting.tscn")


func _on_texture_button_3_pressed() -> void:
	tower_selected.emit(preload("res://scenes/tower/tower_purple.tscn"), 150)

func _on_texture_button_4_pressed() -> void:
	tower_selected.emit(preload("res://scenes/tower/turretpurple.tscn"), 150)
