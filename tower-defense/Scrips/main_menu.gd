extends Control

@export var scene : PackedScene
@export var scene2 : PackedScene

func  _ready() -> void:
	AudioManager.Bg_main.play()
	AudioManager.Bg_gameover.stop()
	AudioManager.Bg_stage.stop()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(scene)
	AudioManager.Bg_main.stop()
	


func _on_setting_pressed() -> void:
	#var current_scene = get_tree().current_scene
	#get_tree().set_meta("previous_scene_path", current_scene.scene_file_path)
	#get_tree().change_scene_to_file("res://scenes/setting.tscn")
	var setting_scene = load("res://scenes/setting.tscn").instantiate()
	get_tree().current_scene.add_child(setting_scene)
