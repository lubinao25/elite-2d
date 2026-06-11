extends Node2D

@export var exit_zone_size: Vector2 = Vector2(140, 60)
@export var exit_zone_position: Vector2 = Vector2(0, 420)

var parking_spots = [
	Vector2(-200, -100),
	Vector2(200, -100),
	Vector2(-200, 150),
	Vector2(200, 150),
]

var station_menu = null
var landed: bool = false
var assigned_pad: int = 1
var station_interface_path: String = "res://scenes/StationInterface.tscn"

func _ready():
	if has_meta("assigned_pad"):
		assigned_pad = get_meta("assigned_pad")

	_build_hangar()
	_setup_exit_zone()
	_setup_landing_zones()
	_show_pad_highlight()

func _build_hangar():
	var floor_rect = ColorRect.new()
	floor_rect.size = Vector2(800, 1000)
	floor_rect.position = Vector2(-400, -500)
	floor_rect.color = Color(0.08, 0.10, 0.15)
	floor_rect.z_index = -10
	add_child(floor_rect)

	_add_wall(Vector2(0, -490), Vector2(800, 20), Color(0.18, 0.20, 0.28))
	_add_wall(Vector2(0, 490), Vector2(800, 20), Color(0.18, 0.20, 0.28))
	_add_wall(Vector2(-410, 0), Vector2(20, 1000), Color(0.18, 0.20, 0.28))
	_add_wall(Vector2(410, 0), Vector2(20, 1000), Color(0.18, 0.20, 0.28))

	_add_slot_visual()

	for i in range(parking_spots.size()):
		_add_parking_spot(parking_spots[i], i + 1)

	_add_grid_lines()

func _add_slot_visual():
	var slot = ColorRect.new()
	slot.size = Vector2(140, 20)
	slot.position = Vector2(-70, 480)
	slot.color = Color(0.0, 0.8, 0.4, 0.6)
	add_child(slot)

	var slot_label = Label.new()
	slot_label.text = "VÝSTUP"
	slot_label.position = Vector2(-35, 458)
	slot_label.add_theme_color_override("font_color", Color(0.0, 1.0, 0.5))
	slot_label.add_theme_font_size_override("font_size", 14)
	add_child(slot_label)

func _add_wall(pos: Vector2, size: Vector2, color: Color):
	var wall = StaticBody2D.new()
	wall.position = pos
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	wall.add_child(shape)
	var vis = ColorRect.new()
	vis.size = size
	vis.position = -size / 2
	vis.color = color
	wall.add_child(vis)
	add_child(wall)

func _add_parking_spot(pos: Vector2, number: int):
	var spot = Node2D.new()
	spot.position = pos
	spot.name = "ParkingSpot%d" % number

	var color_outer: Color
	var color_inner: Color
	var font_color: Color

	if number == assigned_pad:
		color_outer = Color(0.9, 0.8, 0.1, 0.7)
		color_inner = Color(1.0, 0.9, 0.0, 1.0)
		font_color = Color.YELLOW
	else:
		color_outer = Color(0.2, 0.5, 0.8, 0.5)
		color_inner = Color(0.2, 0.5, 0.8, 0.9)
		font_color = Color(0.5, 0.8, 1.0)

	var outer = _make_circle_outline(80, color_outer)
	spot.add_child(outer)
	var inner = _make_circle_outline(35, color_inner)
	spot.add_child(inner)

	var cross_h = ColorRect.new()
	cross_h.size = Vector2(80, 2)
	cross_h.position = Vector2(-40, -1)
	cross_h.color = color_outer
	spot.add_child(cross_h)

	var cross_v = ColorRect.new()
	cross_v.size = Vector2(2, 80)
	cross_v.position = Vector2(-1, -40)
	cross_v.color = color_outer
	spot.add_child(cross_v)

	var label = Label.new()
	label.text = str(number)
	label.position = Vector2(-6, -10)
	label.add_theme_color_override("font_color", font_color)
	label.add_theme_font_size_override("font_size", 18)
	spot.add_child(label)

	add_child(spot)

func _show_pad_highlight():
	var arrow = Label.new()
	arrow.text = "▶ PAD %d" % assigned_pad
	var pad_pos = parking_spots[assigned_pad - 1]
	arrow.position = pad_pos + Vector2(-80, -110)
	arrow.add_theme_color_override("font_color", Color.YELLOW)
	arrow.add_theme_font_size_override("font_size", 14)
	add_child(arrow)

func _make_circle_outline(radius: float, color: Color) -> Node2D:
	var node = Node2D.new()
	var points = PackedVector2Array()
	for i in range(32):
		var angle = (float(i) / 32) * TAU
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	var line = Line2D.new()
	line.points = points
	line.closed = true
	line.width = 2.5
	line.default_color = color
	node.add_child(line)
	return node

func _add_grid_lines():
	for x in range(-4, 5):
		var line = Line2D.new()
		line.add_point(Vector2(x * 90, -480))
		line.add_point(Vector2(x * 90, 480))
		line.width = 1.0
		line.default_color = Color(0.12, 0.14, 0.22)
		add_child(line)
	for y in range(-5, 6):
		var line = Line2D.new()
		line.add_point(Vector2(-400, y * 90))
		line.add_point(Vector2(400, y * 90))
		line.width = 1.0
		line.default_color = Color(0.12, 0.14, 0.22)
		add_child(line)

func _setup_exit_zone():
	var exit_area = Area2D.new()
	exit_area.name = "ExitZone"
	exit_area.position = exit_zone_position

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = exit_zone_size
	shape.shape = rect
	exit_area.add_child(shape)

	exit_area.body_entered.connect(_on_exit_zone_entered)
	add_child(exit_area)

func _setup_landing_zones():
	for i in range(parking_spots.size()):
		var area = Area2D.new()
		area.name = "LandingZone%d" % (i + 1)
		area.position = parking_spots[i]

		var shape = CollisionShape2D.new()
		var circle = CircleShape2D.new()
		circle.radius = 55.0
		shape.shape = circle
		area.add_child(shape)

		area.body_entered.connect(_on_landing_zone_entered.bind(i + 1))
		add_child(area)

func _on_landing_zone_entered(body, pad_number: int):
	if body.name != "Hrac" or landed:
		return

	if pad_number != assigned_pad:
		print("Špatný pad! Přiděleno: %d, přistáno na: %d" % [assigned_pad, pad_number])
		return

	landed = true
	body.velocity = Vector2.ZERO
	body.set_physics_process(false)
	print("Přistáno na padu %d ✓" % pad_number)
	_show_station_menu()

func _show_station_menu():
	if station_menu:
		return

	station_menu = load(station_interface_path).instantiate()

	if station_menu.has_method("setup"):
		var station_name = "Vesmírná stanice"
		if DockingManager and DockingManager.target_station:
			station_name = DockingManager.target_station.station_name
		station_menu.setup(station_name)

	get_tree().root.get_node("Game").add_child(station_menu)

func _hide_station_menu():
	if station_menu:
		station_menu.queue_free()
		station_menu = null

func _on_depart():
	_hide_station_menu()
	landed = false
	var player = get_tree().root.get_node_or_null("Game/Hrac")
	if player:
		player.set_physics_process(true)

func _on_exit_zone_entered(body):
	if body.name == "Hrac" and not landed:
		if DockingManager:
			DockingManager.request_exit_docking()
