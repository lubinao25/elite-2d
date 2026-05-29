extends Control

@export var minimap_width: float = 200.0
@export var minimap_height: float = 200.0
@export var minimap_scale: float = 0.05  # world units to minimap pixels ratio

var player_pos: Vector2 = Vector2.ZERO
var stations: Array = []
var station_colors = [Color.YELLOW, Color.CYAN, Color.LIME, Color.RED]

func _ready():
	stations = get_tree().get_nodes_in_group("stations")
	custom_minimum_size = Vector2(minimap_width, minimap_height)

func _process(_delta):
	var player = get_tree().root.get_node_or_null("Game/Hrac")
	if player:
		player_pos = player.global_position
	queue_redraw()

func _draw():
	# Draw minimap background
	draw_rect(Rect2(0, 0, minimap_width, minimap_height), Color.BLACK)
	draw_rect(Rect2(0, 0, minimap_width, minimap_height), Color.WHITE, false, 1.0)

	var minimap_center = Vector2(minimap_width / 2, minimap_height / 2)

	# Draw all stations with different colors
	for i in range(stations.size()):
		var station = stations[i]
		var color = station_colors[i % station_colors.size()]
		var station_pos = station.global_position - player_pos
		var minimap_pos = minimap_center + station_pos * minimap_scale

		# Always draw station indicators on minimap
		if is_within_bounds(minimap_pos, 100):
			# Station circle
			draw_circle(minimap_pos, 5.0, color)
			# Station outline
			draw_circle(minimap_pos, 5.0, Color.WHITE, false, 1.0)

	# Draw player position as white dot
	draw_circle(minimap_center, 3.0, Color.WHITE)

func is_within_bounds(pos: Vector2, margin: float) -> bool:
	return (pos.x > -margin and pos.x < minimap_width + margin and
			pos.y > -margin and pos.y < minimap_height + margin)

