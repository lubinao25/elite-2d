extends CanvasLayer

var station: Node = null
var refuel_amount: float = 100.0
var refuel_cost: float = 50.0
var repair_amount: float = 50.0
var repair_cost: float = 100.0
var current_missions: Array = []

func _ready():
	$Panel/VBoxContainer/RefuelButton.pressed.connect(_on_refuel)
	$Panel/VBoxContainer/RepairButton.pressed.connect(_on_repair)
	$Panel/VBoxContainer/MissionsButton.pressed.connect(_on_missions)
	$Panel/VBoxContainer/ExitButton.pressed.connect(_on_exit)
	hide()

func show_interface(target_station: Node):
	station = target_station
	$Panel/VBoxContainer/StationName.text = station.station_name
	$Panel/VBoxContainer/MissionsPanel.hide()
	show()

func hide_interface():
	station = null
	hide()

func _on_refuel():
	if not station or not PlayerStats:
		return

	if PlayerStats.spend_money(refuel_cost):
		PlayerStats.refuel(refuel_amount)
		print("Refueled!")
	else:
		print("Not enough money!")

func _on_repair():
	if not station or not PlayerStats:
		return

	if PlayerStats.spend_money(repair_cost):
		PlayerStats.heal(repair_amount)
		print("Repaired!")
	else:
		print("Not enough money!")

func _on_missions():
	var missions_panel = $Panel/VBoxContainer/MissionsPanel
	var missions_list = $Panel/VBoxContainer/MissionsPanel/MissionsList

	if missions_panel.visible:
		missions_panel.hide()
		return

	# Clear old missions
	for child in missions_list.get_children():
		child.queue_free()

	# Get missions for this station
	if station and MissionManager:
		current_missions = MissionManager.get_missions_at_station(station.station_name)

		for mission in current_missions:
			var mission_button = Button.new()
			mission_button.text = mission.get_description()
			mission_button.custom_minimum_size.y = 30
			mission_button.pressed.connect(func(): _on_mission_selected(mission))
			missions_list.add_child(mission_button)

		if current_missions.is_empty():
			var no_missions_label = Label.new()
			no_missions_label.text = "No missions available"
			missions_list.add_child(no_missions_label)

	missions_panel.show()

func _on_mission_selected(mission: Mission):
	if MissionManager:
		MissionManager.accept_mission(mission)
		$Panel/VBoxContainer/MissionsPanel.hide()

func _on_exit():
	hide_interface()
	if DockingManager:
		DockingManager.request_exit_docking()

