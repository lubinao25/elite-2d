extends Node2D

@export var exit_zone_size: Vector2 = Vector2(120, 60)
@export var exit_zone_position: Vector2 = Vector2(0, -460)

var parking_spots = [
	Vector2(-200, -150),
	Vector2(-200, 150),
	Vector2(200, -150),
	Vector2(200, 150),
]

var station_menu: Control = null
var landed: bool = false

func _ready():
	_build_hangar()
	_setup_exit_zone()
	_setup_landing_zones()

func _build_hangar():
	var floor_rect = ColorRect.new()
	floor_rect.size = Vector2(700, 900)
	floor_rect.position = Vector2(-350, -450)
	floor_rect.color = Color(0.1, 0.12, 0.18)
	add_child(floor_rect)
	floor_rect.z_index = -1

	_add_wall(Vector2(0, -460), Vector2(700, 20))
	_add_wall(Vector2(0, 460), Vector2(700, 20))
	_add_wall(Vector2(-360, 0), Vector2(20, 900))
	_add_wall(Vector2(360, 0), Vector2(20, 900))

	for i in range(parking_spots.size()):
		_add_parking_spot(parking_spots[i], i + 1)

	_add_grid_lines()

func _add_wall(pos: Vector2, size: Vector2):
	var wall = StaticBody2D.new()
	wall.collision_layer = 1
	wall.collision_mask = 1
	wall.position = pos
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	wall.add_child(shape)
	var vis = ColorRect.new()
	vis.size = size
	vis.position = -size / 2
	vis.color = Color(0.2, 0.22, 0.3)
	wall.add_child(vis)
	add_child(wall)

func _add_parking_spot(pos: Vector2, number: int):
	var spot = Node2D.new()
	spot.position = pos
	spot.name = "ParkingSpot%d" % number

	var outer = _make_circle_outline(80, Color(0.2, 0.5, 0.8, 0.6))
	spot.add_child(outer)
	var inner = _make_circle_outline(35, Color(0.2, 0.5, 0.8, 0.9))
	spot.add_child(inner)

	var cross_h = ColorRect.new()
	cross_h.size = Vector2(80, 2)
	cross_h.position = Vector2(-40, -1)
	cross_h.color = Color(0.2, 0.5, 0.8, 0.5)
	spot.add_child(cross_h)

	var cross_v = ColorRect.new()
	cross_v.size = Vector2(2, 80)
	cross_v.position = Vector2(-1, -40)
	cross_v.color = Color(0.2, 0.5, 0.8, 0.5)
	spot.add_child(cross_v)

	var label = Label.new()
	label.text = str(number)
	label.position = Vector2(-6, -10)
	label.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
	spot.add_child(label)

	add_child(spot)

func _make_circle_outline(radius: float, color: Color) -> Node2D:
	var node = Node2D.new()
	var points = PackedVector2Array()
	var segments = 32
	for i in range(segments):
		var angle = (float(i) / segments) * TAU
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	var line = Line2D.new()
	line.points = points
	line.closed = true
	line.width = 2.0
	line.default_color = color
	node.add_child(line)
	return node

func _add_grid_lines():
	for x in range(-3, 4):
		var line = Line2D.new()
		line.add_point(Vector2(x * 100, -450))
		line.add_point(Vector2(x * 100, 450))
		line.width = 1.0
		line.default_color = Color(0.15, 0.17, 0.25)
		add_child(line)
	for y in range(-4, 5):
		var line = Line2D.new()
		line.add_point(Vector2(-350, y * 100))
		line.add_point(Vector2(350, y * 100))
		line.width = 1.0
		line.default_color = Color(0.15, 0.17, 0.25)
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

	var door_vis = ColorRect.new()
	door_vis.size = exit_zone_size
	door_vis.position = -exit_zone_size / 2
	door_vis.color = Color(0.0, 0.5, 0.3, 0.4)
	exit_area.add_child(door_vis)

	var door_label = Label.new()
	door_label.text = "VÝSTUP"
	door_label.position = Vector2(-25, -10)
	door_label.add_theme_color_override("font_color", Color(0.0, 1.0, 0.5))
	exit_area.add_child(door_label)

	exit_area.body_entered.connect(_on_exit_zone_entered)
	add_child(exit_area)

func _setup_landing_zones():
	for i in range(parking_spots.size()):
		var area = Area2D.new()
		area.name = "LandingZone%d" % (i + 1)
		area.position = parking_spots[i]
		area.set_meta("spot_index", i)

		var shape = CollisionShape2D.new()
		var circle = CircleShape2D.new()
		circle.radius = 50.0
		shape.shape = circle
		area.add_child(shape)

		area.body_entered.connect(_on_landing_zone_entered.bind(i))
		area.body_exited.connect(_on_landing_zone_exited.bind(i))
		add_child(area)

func _on_landing_zone_entered(body, spot_index: int):
	if body.name == "Hrac" and not landed:
		landed = true
		body.velocity = Vector2.ZERO
		body.set_physics_process(false)
		print("Přistál na místě %d" % (spot_index + 1))
		_show_station_menu()

func _on_landing_zone_exited(body, _spot_index: int):
	if body.name == "Hrac":
		landed = false

func _show_station_menu():
	if station_menu:
		return

	station_menu = Control.new()
	station_menu.set_anchors_preset(Control.PRESET_CENTER)
	station_menu.z_index = 10

	var panel = PanelContainer.new()
	panel.position = Vector2(-150, -120)
	panel.custom_minimum_size = Vector2(300, 240)
	station_menu.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var title = Label.new()
	title.text = "== STANICE =="
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
	vbox.add_child(title)

	var btn_trade = Button.new()
	btn_trade.text = "Obchod"
	btn_trade.pressed.connect(_on_menu_trade)
	vbox.add_child(btn_trade)

	var btn_repair = Button.new()
	btn_repair.text = "Opravit loď"
	btn_repair.pressed.connect(_on_menu_repair)
	vbox.add_child(btn_repair)

	var btn_leave = Button.new()
	btn_leave.text = "Odletět"
	btn_leave.pressed.connect(_on_menu_leave)
	vbox.add_child(btn_leave)

	add_child(station_menu)

func _hide_station_menu():
	if station_menu:
		station_menu.queue_free()
		station_menu = null

func _on_menu_trade():
	print("TODO: otevřít obchod")

func _on_menu_repair():
	print("TODO: opravit loď")

func _on_menu_leave():
	_hide_station_menu()
	landed = false
	var player = get_tree().root.get_node_or_null("Game/Hrac")
	if player:
		player.set_physics_process(true)
	if DockingManager:
		DockingManager.request_exit_docking()

func _on_exit_zone_entered(body):
	if body.name == "Hrac":
		_hide_station_menu()
		if DockingManager:
			DockingManager.request_exit_docking()
