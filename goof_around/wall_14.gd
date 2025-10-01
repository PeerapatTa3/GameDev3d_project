extends CSGBox3D

func _physics_process(delta: float) -> void:
	rotation.y += delta * 3
	$"../CollisionShape3D".rotation = rotation
