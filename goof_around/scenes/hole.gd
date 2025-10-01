extends Node3D

@export var to_stage : PackedScene
@export var ui : UI

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and to_stage:
		get_tree().call_deferred("change_scene_to_packed", to_stage)
	elif body.is_in_group("Player"):
		ui.finish_game()
