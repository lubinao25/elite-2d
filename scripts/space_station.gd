extends Area2D

@export var station_name: String = "Space Station Alpha"
@export var poi_distance_from_edge: float = 30.0
@export var fuel_price: float = 5.0
@export var repair_price: float = 10.0
@export var docking_distance: float = 200.0

var camera: Camera2D
var poi: Node2D
var is_player_docking: bool = false

func _ready():
	_create_poi()
	if StationManager:
		StationManager.register_station(self)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _create_poi():
	poi = Node2D.new()
	poi.name = "POI"
	add_child(poi)

	var poi_polygon = Polygon2D.new()
	poi_polygon.polygon = PackedVector2Array([
		Vector2(0, -8),
		Vector2(-6, 6),
		Vector2(6, 6)
	])
	poi_polygon.color = Color.YELLOW
	poi.add_child(poi_polygon)

func _process(_delta):
	if camera == null:
		camera = get_tree().root.get_camera_2d()
		return

	if poi == null:
		return

	_update_poi_position()

func _update_poi_position():
	var viewport_size = get_viewport().get_visible_rect().size
	var camera_pos = camera.global_position
	var station_screen_pos = global_position - camera_pos

	var margin = 50.0
	var is_on_screen = (
		abs(station_screen_pos.x) < viewport_size.x / 2 + margin and
		abs(station_screen_pos.y) < viewport_size.y / 2 + margin
	)

	if is_on_screen:
		poi.position = Vector2.ZERO
		poi.visible = true
	else:
		poi.visible = true
		var clamped_pos = station_screen_pos.clamp(
			-viewport_size / 2 + Vector2(poi_distance_from_edge, poi_distance_from_edge),
			viewport_size / 2 - Vector2(poi_distance_from_edge, poi_distance_from_edge)
		)
		poi.position = clamped_pos

		var direction_to_station = (station_screen_pos - clamped_pos).normalized()
		poi.rotation = direction_to_station.angle() + PI/2

func _on_area_entered(area):
	if area.name == "Hrac":
		print("Player near station: " + station_name)
		is_player_docking = true

func _on_area_exited(area):
	if area.name == "Hrac":
		is_player_docking = false

func get_distance_to_player() -> float:
	var player = get_tree().root.get_node_or_null("Game/Hrac")
	if player:
		return global_position.distance_to(player.global_position)
	return INF
