extends CanvasLayer



func _on_back_pressed() -> void:
	if get_tree().has_meta("previous_scene_path"):
		var prev = get_tree().get_meta("previous_scene_path")
		get_tree().change_scene_to_file(prev)
