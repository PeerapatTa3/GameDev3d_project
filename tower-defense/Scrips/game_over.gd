extends Control

@export var Scene : PackedScene

func  _ready() -> void:
	GameStatus.hp = 10
	AudioManager.Bg_gameover.play()
	$TextureRect/Wave.text = "You survived for (" + str(GameStatus.wave) + ") waves!!"


func _on_mainmenu_pressed() -> void:
	get_tree().change_scene_to_packed(Scene)
