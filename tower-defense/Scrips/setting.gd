extends CanvasLayer

@export var Bus_name : String
var Bus_id
@onready var audio_music_control = $TextureRect/Audio_music_control

func _ready() -> void:
	Bus_id = AudioServer.get_bus_index(Bus_name)
	
	var current_db = AudioServer.get_bus_volume_db(Bus_id)

func _on_back_pressed() -> void:
	#if get_tree().has_meta("previous_scene_path"):
		#var prev = get_tree().get_meta("previous_scene_path")
		#get_tree().change_scene_to_file(prev)
		queue_free()


func _on_audio_music_control_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(Bus_id,value)
