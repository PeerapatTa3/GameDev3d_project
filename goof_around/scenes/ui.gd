extends CanvasLayer
class_name UI

func _ready() -> void:
	$finish.hide()

func finish_game():
	$finish.show()
