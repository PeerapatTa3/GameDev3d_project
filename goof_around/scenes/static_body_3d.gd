extends Area3D

func _on_body_entered(body: Node3D) -> void:
	body.position = body.original_position
