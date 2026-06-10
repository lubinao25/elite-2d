extends Node2D

@export var exit_zone_size: Vector2 = Vector2(120, 60)
@export var exit_zone_position: Vector2 = Vector2(0, -460)

var parking_spots = [
	Vector2(-200, -150),  # vlevo nahoře
	Vector2(-200, 150),   # vlevo dole
	Vector2(200, -150),   # vpravo nahoře
	Vector2(200, 150),    # vpravo dole
]
var occupied_spots = [false, false, false, false]

func _ready():
	_build_hangar()
	_setup_exit_zone()

func _build_hangar():
	# Podlaha
	var floor_rect = ColorRect.new()
	floor_rect.size = Vector2(700, 900)
	floor_rect.position = Vector2(-350, -450)
	floor_rect.color = Color(0.1, 0.12, 0.18)
	add_child(floor_rect)
	floor_rect.z_index = -1

	# Zdi (4 strany) jako StaticBody2D
	_add_wall(Vector2(0, -460), Vector2(700, 20))   # horní zeď
	_add_wall(Vector2(0, 460), Vector2(700, 20))    # dolní zeď
	_add_wall(Vector2(-360, 0), Vector2(20, 900))   # levá zeď
	_add_wall(Vector2(360, 0), Vector2(20, 900))    # pravá zeď

	# Parkovací místa
	for i in range(parking_spots.size()):
		_add_parking_spot(parking_spots[i], i + 1)

	# Mřížkové čáry (dekorace)
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
	# Vizuál zdi
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

	# Kruh - vnější
	var outer = _make_circle_outline(80, Color(0.2, 0.5, 0.8, 0.6))
	spot.add_child(outer)

	# Kruh - vnitřní
	var inner = _make_circle_outline(35, Color(0.2, 0.5, 0.8, 0.9))
	spot.add_child(inner)

	# Kříž uprostřed
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

	# Číslo
	var label = Label.new()
	label.text = str(number)
	label.position = Vector2(-6, -10)
	label.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
	spot.add_child(label)

	add_child(spot)

func _make_circle_outline(radius: float, color: Color) -> Node2D:
	var node = Node2D.new()
	# Aproximace kruhu pomocí polygonu
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
	# Area2D pro výstup (dveře nahoře)
	var exit_area = Area2D.new()
	exit_area.name = "ExitZone"
	exit_area.position = exit_zone_position

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = exit_zone_size
	shape.shape = rect
	exit_area.add_child(shape)

	# Vizuál dveří
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

func _on_exit_zone_entered(body):
	if body.name == "Hrac":
		print("Player exiting station...")
		if DockingManager:
			DockingManager.request_exit_docking()
