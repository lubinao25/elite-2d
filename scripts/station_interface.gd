extends CanvasLayer

signal exit_requested

func _ready():
	# Propoj tlačítka ze scény
	$Panel/VBoxContainer/RefuelButton.pressed.connect(_on_refuel)
	$Panel/VBoxContainer/RepairButton.pressed.connect(_on_repair)
	$Panel/VBoxContainer/MissionsButton.pressed.connect(_on_missions)
	$Panel/VBoxContainer/ExitButton.pressed.connect(_on_exit)
	$Panel/VBoxContainer/MissionsPanel.visible = false

func setup(station_name: String):
	$Panel/VBoxContainer/StationName.text = station_name

func _on_refuel():
	print("TODO: doplnit palivo")

func _on_repair():
	print("TODO: opravit loď")

func _on_missions():
	var panel = $Panel/VBoxContainer/MissionsPanel
	panel.visible = not panel.visible

func _on_exit():
	exit_requested.emit()
	if DockingManager:
		DockingManager.request_exit_docking()
	queue_free()
