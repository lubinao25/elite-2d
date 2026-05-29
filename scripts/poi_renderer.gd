extends Control

@export var minimap_width: float = 200.0
@export var minimap_height: float = 200.0
@export var minimap_scale: float = 0.05
@export var arrow_margin: float = 15.0

var player_pos: Vector2 = Vector2.ZERO
var stations: Array = []
var station_colors = [Color.YELLOW, Color.CYAN, Color.LIME, Color.RED]
var viewport_size: Vector2 = Vector2.ZERO

func _ready():
	stations = get_tree().get_nodes_in_group("stations")
	viewport_size = get_viewport().get_visible_rect().size

func _process(_delta):
	var player = get_tree().root.get_node_or_null("Game/Hrac")
	if player:
		player_pos = player.global_position
	queue_redraw()

func _draw():
	var minimap_center = Vector2(minimap_width / 2, minimap_height / 2)
	var camera = get_tree().root.get_camera_2d()

	# Draw POI for stations with active missions
	for i in range(stations.size()):
		var station = stations[i]
		var has_mission = has_mission_for_station(station)

		if not has_mission:
			continue

		var color = station_colors[i % station_colors.size()]
		var station_screen_pos = station.global_position - (camera.global_position if camera else player_pos)

		# Check if station is on screen
		var is_on_screen = (
			abs(station_screen_pos.x) < viewport_size.x / 2 + 100 and
			abs(station_screen_pos.y) < viewport_size.y / 2 + 100
		)

		if is_on_screen:
			# Draw circle (station is visible)
			var screen_pos = camera.get_screen_center_position() + station_screen_pos if camera else player_pos + station_screen_pos
			draw_circle_on_minimap(minimap_center, station.global_position - player_pos, 6.0, color)
		else:
			# Draw arrow pointing off-screen
			draw_arrow_on_minimap(minimap_center, station.global_position - player_pos, color)

func draw_circle_on_minimap(minimap_center: Vector2, station_offset: Vector2, radius: float, color: Color):
	var minimap_pos = minimap_center + station_offset * minimap_scale
	if is_minimap_position_valid(minimap_pos):
		draw_circle(minimap_pos, radius, color)
		draw_circle(minimap_pos, radius, Color.WHITE, false, 1.0)

func draw_arrow_on_minimap(minimap_center: Vector2, station_offset: Vector2, color: Color):
	var station_direction = station_offset.normalized()
	var arrow_pos = minimap_center + station_direction * (Vector2(minimap_width, minimap_height).length() / 2 - arrow_margin)

	# Draw arrow as triangle
	var arrow_size = 8.0
	var perpendicular = Vector2(-station_direction.y, station_direction.x)

	var triangle = PackedVector2Array([
		arrow_pos + station_direction * arrow_size,
		arrow_pos - perpendicular * arrow_size / 2,
		arrow_pos + perpendicular * arrow_size / 2
	])

	draw_colored_polygon(triangle, color)
	draw_polyline(triangle, Color.WHITE, 1.0)

func is_minimap_position_valid(pos: Vector2) -> bool:
	return (pos.x > -10 and pos.x < minimap_width + 10 and
			pos.y > -10 and pos.y < minimap_height + 10)

func has_mission_for_station(station: Node) -> bool:
	if not MissionManager:
		return false

	var active = MissionManager.get_active_mission()
	if active and (active.source_station == station.station_name or active.destination_station == station.station_name):
		return true

	return false
