extends Node

enum DockingState {
	NORMAL_FLIGHT,
	DOCKING_APPROACH,
	DOCKING_DOORS,
	DOCKING_LANDING,
	DOCKED,
	DOCKING_EXIT
}

var current_state: DockingState = DockingState.NORMAL_FLIGHT
var target_station: Node = null
var docking_ui: Node = null

@export var approach_distance: float = 400.0
@export var door_tolerance: float = 80.0
@export var landing_distance: float = 50.0

signal state_changed(new_state: DockingState)
signal docking_failed(reason: String)

func _ready():
	pass

func _process(delta):
	match current_state:
		DockingState.NORMAL_FLIGHT:
			_check_for_station_approach()
		DockingState.DOCKING_APPROACH:
			_handle_approach()
		DockingState.DOCKING_DOORS:
			_handle_door_navigation(delta)
		DockingState.DOCKING_LANDING:
			_handle_landing(delta)
		DockingState.DOCKED:
			pass
		DockingState.DOCKING_EXIT:
			_handle_exit(delta)

func _check_for_station_approach():
	var player = get_tree().root.get_node_or_null("Game/Hrac")
	if not player or not StationManager:
		print("DEBUG: Missing player or StationManager")
		return

	var nearest_station = StationManager.get_nearest_station(player.global_position)
	if nearest_station:
		var dist = player.global_position.distance_to(nearest_station.global_position)
		print("DEBUG: Nearest station: %s at distance %.0f (threshold: %.0f)" % [nearest_station.station_name, dist, approach_distance])
		if dist < approach_distance:
			target_station = nearest_station
			set_docking_state(DockingState.DOCKING_APPROACH)
			print("Station %s in approach range!" % nearest_station.station_name)
	else:
		print("DEBUG: No nearest station found. Total stations: %d" % StationManager.stations.size())

func _handle_approach():
	if not target_station:
		set_docking_state(DockingState.NORMAL_FLIGHT)
		return

	var player = get_tree().root.get_node_or_null("Game/Hrac")
	if not player:
		return

	var distance = player.global_position.distance_to(target_station.global_position)

	if distance > approach_distance + 50:
		set_docking_state(DockingState.NORMAL_FLIGHT)
		target_station = null
		return

	if distance < 150:
		set_docking_state(DockingState.DOCKING_DOORS)

func _handle_door_navigation(_delta):
	if not target_station:
		_fail_docking("Lost target station")
		return

	var player = get_tree().root.get_node_or_null("Game/Hrac")
	if not player:
		return

	var distance = player.global_position.distance_to(target_station.global_position)

	# Check if player is too close to station (collision with edges)
	if distance < door_tolerance:
		set_docking_state(DockingState.DOCKING_LANDING)
		print("Passed through doors successfully!")
		return

	if distance > approach_distance:
		_fail_docking("Left approach zone")

func _handle_landing(_delta):
	if not target_station:
		_fail_docking("Lost target station during landing")
		return

	var player = get_tree().root.get_node_or_null("Game/Hrac")
	if not player:
		return

	var distance = player.global_position.distance_to(target_station.global_position)

	if distance < landing_distance:
		set_docking_state(DockingState.DOCKED)
		print("Successfully docked at %s!" % target_station.station_name)
		if PlayerStats:
			PlayerStats.update_speed(0.0)
		player.velocity = Vector2.ZERO
	elif distance > 200:
		_fail_docking("Missed landing platform")

func _handle_exit(_delta):
	if not target_station:
		set_docking_state(DockingState.NORMAL_FLIGHT)
		return

	var player = get_tree().root.get_node_or_null("Game/Hrac")
	if not player:
		return

	var distance = player.global_position.distance_to(target_station.global_position)

	if distance > approach_distance:
		set_docking_state(DockingState.NORMAL_FLIGHT)
		target_station = null
		print("Exited station successfully!")

func set_docking_state(new_state: DockingState):
	if current_state != new_state:
		current_state = new_state
		state_changed.emit(new_state)

func request_exit_docking():
	if current_state == DockingState.DOCKED:
		set_docking_state(DockingState.DOCKING_EXIT)

func _fail_docking(reason: String):
	print("Docking failed: %s" % reason)
	docking_failed.emit(reason)
	if PlayerStats:
		PlayerStats.take_damage(50.0)
	set_docking_state(DockingState.NORMAL_FLIGHT)
	target_station = null
