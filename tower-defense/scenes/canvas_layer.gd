extends CanvasLayer

signal tower_selected(scene: PackedScene, cost: int)

func _ready():
	tower_selected.connect(func(scene, cost):
		print("UI emitted tower:", scene, "cost:", cost))

func _on_texture_button_pressed() -> void:
		tower_selected.emit(preload("res://scenes/tower/test_tower.tscn"), 50)
