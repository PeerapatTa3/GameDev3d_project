extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Enemy"):
		body.queue_free()
		GameStatus.hp -= 1
		GameStatus.enemies_remaining -= 1
		print(GameStatus.hp)
