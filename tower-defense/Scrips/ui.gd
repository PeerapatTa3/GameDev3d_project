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
		tower_selected.emit(preload("res://scenes/cannon.tscn"), 50)

func _process(delta: float) -> void:
	coin.text = str(GameStatus.coin)

func _on_coin_pressed() -> void:
	GameStatus.coin += 100


func _on_texture_button_2_pressed() -> void:
	tower_selected.emit(preload("res://scenes/turret.tscn"), 100)
