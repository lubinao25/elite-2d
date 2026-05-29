extends Node

var available_missions: Array = []
var active_mission: Mission = null

func _ready():
	_generate_missions()

func _process(delta):
	if active_mission and active_mission.is_active:
		_check_mission_completion()

func _generate_missions():
	available_missions.clear()

	var stations = ["Station Alpha", "Station Beta", "Station Gamma", "Station Delta"]

	for i in range(10):
		var source = stations[randi() % stations.size()]
		var dest = stations[randi() % stations.size()]

		while dest == source:
			dest = stations[randi() % stations.size()]

		var mission = Mission.new(
			"mission_%d" % i,
			source,
			dest,
			randf_range(100, 500)
		)
		available_missions.append(mission)

func get_missions_at_station(station_name: String) -> Array:
	var station_missions = []
	for mission in available_missions:
		if mission.source_station == station_name and not mission.is_active:
			station_missions.append(mission)
	return station_missions

func accept_mission(mission: Mission):
	if mission in available_missions:
		active_mission = mission
		mission.is_active = true
		if PlayerStats:
			PlayerStats.add_cargo(mission.cargo_amount)
		print("Mission accepted: %s" % mission.get_description())

func _check_mission_completion():
	if not active_mission or not active_mission.is_active:
		return

	var player = get_tree().root.get_node_or_null("Game/Hrac")
	if not player or not DockingManager:
		return

	var current_station = DockingManager.target_station
	if current_station and current_station.station_name == active_mission.destination_station:
		if DockingManager.current_state == DockingManager.DockingState.DOCKED:
			complete_mission()

func complete_mission():
	if not active_mission:
		return

	print("Mission completed!")
	if PlayerStats:
		PlayerStats.add_money(active_mission.reward)
		PlayerStats.remove_cargo(active_mission.cargo_amount)

	active_mission.is_completed = true
	available_missions.erase(active_mission)
	active_mission = null

func get_active_mission() -> Mission:
	return active_mission

func get_available_missions() -> Array:
	return available_missions
