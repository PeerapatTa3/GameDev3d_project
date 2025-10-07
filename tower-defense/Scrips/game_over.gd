extends Control

@export var Scene : PackedScene

func  _ready() -> void:
	AudioManager.Bg_gameover.play()




func _on_mainmenu_pressed() -> void:
	get_tree().change_scene_to_packed(Scene)
