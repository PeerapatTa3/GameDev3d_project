extends Node

func _ready() -> void:
	var placement_ui = $UI
	var placement_manager = $Placementmanager

	# Make sure UI has the signal defined
	placement_ui.tower_selected.connect(placement_manager.select_tower)
