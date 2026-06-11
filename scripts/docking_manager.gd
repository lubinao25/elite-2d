extends Node

enum DockingState {
	NORMAL_FLIGHT,
	IN_RANGE,        # hráč je blízko, může požádat o přistání
	PERMISSION_GRANTED, # povolení uděleno, čeká se na vstup do mail slotu
	INSIDE_STATION,  # uvnitř hangáru, hledá přistávací pad
	DOCKED,          # přistáno, menu zobrazeno
	DEPARTING        # odletí, čeká na průlet mail slotem ven
}

var current_state: DockingState = DockingState.NORMAL_FLIGHT
var target_station: Node = null
var interior_scene: Node = null
var in_interior: bool = false
var assigned_pad: int = 1  # přidělené číslo padu (1-4)

@export var request_distance: float = 500.0   # vzdálenost pro zobrazení výzvy
@export var mail_slot_distance: float = 80.0  # vzdálenost pro detekci průletu mail slotem
@export var interior_scene_path: String = "res://scenes/StationInterior.tscn"

signal state_changed(new_state: DockingState)
signal docking_permission_granted(pad_number: int)
signal docking_denied(reason: String)

var _hud_hint: Label = null

func _ready():
	_create_hud_hint()

func _create_hud_hint():
	_hud_hint = Label.new()
	_hud_hint.visible = false
	_hud_hint.z_index = 100
	_hud_hint.add_theme_color_override("font_color", Color(0.0, 1.0, 0.5))
	_hud_hint.add_theme_font_size_override("font_size", 16)
	# Přidá se do CanvasLayer aby bylo vždy nad hrou
	var canvas = CanvasLayer.new()
	canvas.layer = 10
	add_child(canvas)
	canvas.add_child(_hud_hint)

func _process(_delta):
	match current_state:
		DockingState.NORMAL_FLIGHT:
			_check_range()
		DockingState.IN_RANGE:
			_check_range()
			_check_permission_input()
		DockingState.PERMISSION_GRANTED:
			_check_mail_slot_entry()
		DockingState.DEPARTING:
			_check_mail_slot_exit()

func _check_range():
	var player = _get_player()
	if not player or not StationManager:
		return

	var nearest = StationManager.get_nearest_station(player.global_position)
	if not nearest:
		_set_hint_visible(false)
		if current_state == DockingState.IN_RANGE:
			set_docking_state(DockingState.NORMAL_FLIGHT)
		return

	var dist = player.global_position.distance_to(nearest.global_position)

	if dist < request_distance:
		target_station = nearest
		if current_state == DockingState.NORMAL_FLIGHT:
			set_docking_state(DockingState.IN_RANGE)
		_set_hint("[F] Požádat o přistání: %s" % nearest.station_name, Vector2(20, 80))
	else:
		target_station = null
		_set_hint_visible(false)
		if current_state == DockingState.IN_RANGE:
			set_docking_state(DockingState.NORMAL_FLIGHT)

func _check_permission_input():
	if Input.is_action_just_pressed("request_docking"):
		_request_docking_permission()

func _request_docking_permission():
	if not target_station:
		return

	# Přiděl náhodný volný pad (1-4)
	assigned_pad = randi_range(1, 4)
	set_docking_state(DockingState.PERMISSION_GRANTED)

	_set_hint("Povolení uděleno. Pad %d. Proletěte vstupem." % assigned_pad, Vector2(20, 80))
	docking_permission_granted.emit(assigned_pad)
	print("Docking permission granted: pad %d" % assigned_pad)

func _check_mail_slot_entry():
	var player = _get_player()
	if not player or not target_station:
		return

	var dist = player.global_position.distance_to(target_station.global_position)

	if dist < mail_slot_distance:
		_enter_station()

func _enter_station():
	var player = _get_player()
	if not player:
		return

	in_interior = true
	set_docking_state(DockingState.INSIDE_STATION)
	_set_hint("Přistaňte na padu %d" % assigned_pad, Vector2(20, 80))

	var game = get_tree().root.get_node_or_null("Game")
	if not game:
		return

	interior_scene = load(interior_scene_path).instantiate()
	# Předej číslo přiděleného padu interiéru
	interior_scene.set_meta("assigned_pad", assigned_pad)
	game.add_child(interior_scene)

	# Hráč se spawn dole u vstupu hangáru
	player.global_position = Vector2(0, 380)
	player.velocity = Vector2.ZERO

	print("Vstoupil do stanice, pad: %d" % assigned_pad)

func _check_mail_slot_exit():
	# Volá se z interior scény přes request_exit_docking()
	pass

func request_exit_docking():
	if not in_interior:
		return

	var player = _get_player()

	in_interior = false
	set_docking_state(DockingState.DEPARTING)
	_set_hint("Odlétáte...", Vector2(20, 80))

	if interior_scene:
		interior_scene.queue_free()
		interior_scene = null

	if player and target_station:
		player.global_position = target_station.global_position + Vector2(200, 0)
		player.velocity = Vector2(150, 0)  # malý impulz ven od stanice
		player.set_physics_process(true)

	await get_tree().create_timer(1.5).timeout
	target_station = null
	_set_hint_visible(false)
	set_docking_state(DockingState.NORMAL_FLIGHT)
	print("Odletěl ze stanice.")

func set_docking_state(new_state: DockingState):
	if current_state != new_state:
		current_state = new_state
		state_changed.emit(new_state)

func _get_player() -> Node:
	return get_tree().root.get_node_or_null("Game/Hrac")

func _set_hint(text: String, pos: Vector2 = Vector2(20, 80)):
	if _hud_hint:
		_hud_hint.text = text
		_hud_hint.position = pos
		_hud_hint.visible = true

func _set_hint_visible(vis: bool):
	if _hud_hint:
		_hud_hint.visible = vis
