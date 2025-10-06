extends Node
class_name Upgrade_UI

var mouse_handler : MouseHandler
var upgrade_traget : Tower = null

func _ready() -> void:
	mouse_handler = get_tree().get_first_node_in_group("MouseHandler")
	$CanvasLayer.hide()

func _upgrade_open(body : Node)->void:
	if not body is Tower:
		return
	$CanvasLayer.show()
	upgrade_traget = body
	_input_tower_stat()

func _input_tower_stat():
	$CanvasLayer/Panel/NameTower.text = upgrade_traget.tower_name
	$CanvasLayer/VBoxContainer/Level/Old_Level.text = str(upgrade_traget.upgrade_level)
	$CanvasLayer/VBoxContainer/Level/New_Level.text = str(upgrade_traget.upgrade_level + 1)
	$CanvasLayer/VBoxContainer/Damage/Old_damage.text = str(upgrade_traget.bullet_damage)
	$CanvasLayer/VBoxContainer/Damage/New_damage.text = str(upgrade_traget.bullet_damage + upgrade_traget.upgrade_damage_bonus)
	$CanvasLayer/VBoxContainer/Range/Old_Range.text = "%.1f" % [upgrade_traget.attack_shape.radius]
	$CanvasLayer/VBoxContainer/Range/New_Range.text = "%.1f" % [upgrade_traget.attack_shape.radius + upgrade_traget.upgrade_range_bonus]
	
	if upgrade_traget.upgrade_level >= upgrade_traget.max_upgrade_level:
		$CanvasLayer/VBoxContainer/Level/arrow3.hide()
		$CanvasLayer/VBoxContainer/Level/New_Level.text = "Max Level"
		$CanvasLayer/VBoxContainer/Damage/arrow.hide()
		$CanvasLayer/VBoxContainer/Damage/New_damage.hide()
		$CanvasLayer/VBoxContainer/Range/arrow2.hide()
		$CanvasLayer/VBoxContainer/Range/New_Range.hide()
	else :
		$CanvasLayer/VBoxContainer/Level/arrow3.show()
		$CanvasLayer/VBoxContainer/Level/New_Level.show()
		$CanvasLayer/VBoxContainer/Damage/arrow.show()
		$CanvasLayer/VBoxContainer/Damage/New_damage.show()
		$CanvasLayer/VBoxContainer/Range/arrow2.show()
		$CanvasLayer/VBoxContainer/Range/New_Range.show()
	


func _close_upgrade_menu()->void:
	$CanvasLayer.hide()
	upgrade_traget = null

func _on_sell_pressed() -> void:
	mouse_handler.occupied_cells.erase(mouse_handler._cell_key(upgrade_traget.placed_cell))
	upgrade_traget.queue_free()
	_close_upgrade_menu()

func _on_upgrade_pressed() -> void:
	upgrade_traget._on_tower_clicked()
	_input_tower_stat()

func _on_close_pressed() -> void:
	_close_upgrade_menu()
