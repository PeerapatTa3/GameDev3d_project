extends Control

@onready var map1 : PackedScene = preload("res://scenes/test.tscn")
@onready var map2 : PackedScene = preload("res://Map/grass_land.tscn")

@export var scene2 : PackedScene

var to_scene : PackedScene

func  _ready() -> void:
	to_scene = map1
	AudioManager.Bg_main.play()
	AudioManager.Bg_gameover.stop()
	AudioManager.Bg_stage.stop()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(to_scene)
	AudioManager.Bg_main.stop()
	AudioManager.Bg_stage.play()
	

func _on_setting_pressed() -> void:
	#var current_scene = get_tree().current_scene
	#get_tree().set_meta("previous_scene_path", current_scene.scene_file_path)
	#get_tree().change_scene_to_file("res://scenes/setting.tscn")
	var setting_scene = load("res://scenes/setting.tscn").instantiate()
	get_tree().current_scene.add_child(setting_scene)

func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			to_scene = map1
		1:
			to_scene = map2
		_:
			to_scene = map1
