extends Node

enum DockingState {
	NORMAL_FLIGHT,
	DOCKING_APPROACH,
	DOCKED,
	DOCKING_EXIT
}

var current_state: DockingState = DockingState.NORMAL_FLIGHT
var target_station: Node = null
var interior_scene: Node = null
var in_interior: bool = false

@export var approach_distance: float = 400.0
@export var interior_scene_path: String = "res://scenes/StationInterior.tscn"

signal state_changed(new_state: DockingState)

func _ready():
	pass

func _process(_delta):
	match current_state:
		DockingState.NORMAL_FLIGHT:
			_check_for_station_approach()
		DockingState.DOCKING_APPROACH:
			pass
		DockingState.DOCKED:
			pass
		DockingState.DOCKING_EXIT:
			pass

func _check_for_station_approach():
	var player = get_tree().root.get_node_or_null("Game/Hrac")
	if not player or not StationManager:
		return

	var nearest_station = StationManager.get_nearest_station(player.global_position)
	if nearest_station:
		var dist = player.global_position.distance_to(nearest_station.global_position)
		if dist < approach_distance:
			target_station = nearest_station
			_teleport_to_interior()

func _teleport_to_interior():
	if in_interior:
		return

	var player = get_tree().root.get_node_or_null("Game/Hrac")
	if not player:
		return

	# Zmraz loď
	player.velocity = Vector2.ZERO
	if player.has_method("set_physics_process"):
		player.set_physics_process(false)
		player.set_process_input(false)

	set_docking_state(DockingState.DOCKING_APPROACH)

	var game = get_tree().root.get_node_or_null("Game")
	if not game:
		return

	in_interior = true
	interior_scene = load(interior_scene_path).instantiate()
	game.add_child(interior_scene)

	# Přesuň hráče na spawn v interiéru
	player.global_position = Vector2(0, 300)  # dole v hangáru
	player.set_physics_process(true)
	player.set_process_input(true)

	set_docking_state(DockingState.DOCKED)
	print("Teleportován do stanice: %s" % target_station.station_name)

func request_exit_docking():
	if not in_interior:
		return

	var player = get_tree().root.get_node_or_null("Game/Hrac")

	# Odstraň interiér
	in_interior = false
	if interior_scene:
		interior_scene.queue_free()
		interior_scene = null

	# Přesuň hráče zpět do vesmíru vedle stanice
	if player and target_station:
		player.global_position = target_station.global_position + Vector2(200, 0)
		player.velocity = Vector2.ZERO

	target_station = null
	set_docking_state(DockingState.DOCKING_EXIT)
	await get_tree().create_timer(0.1).timeout
	set_docking_state(DockingState.NORMAL_FLIGHT)
	print("Odletěl ze stanice")

func set_docking_state(new_state: DockingState):
	if current_state != new_state:
		current_state = new_state
		state_changed.emit(new_state)