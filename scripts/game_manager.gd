extends Node

func _ready():
	if DockingManager:
		DockingManager.state_changed.connect(_on_docking_state_changed)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file("res://scenes/Menu.tscn")

func _on_docking_state_changed(new_state):
	var station_interface = get_node_or_null("StationInterface")
	if not station_interface:
		return

	if new_state == DockingManager.DockingState.DOCKED:
		station_interface.show_interface(DockingManager.target_station)
	else:
		station_interface.hide_interface()

