extends Node2D

@export var star_count: int = 200
@export var spawn_radius: float = 2000.0
@export var parallax_depth: float = 0.8

var stars: PackedVector2Array = []
var camera: Camera2D

func _ready():
	# Generate initial stars
	_generate_stars()

func _generate_stars():
	stars.clear()
	randomize()
	for i in range(star_count):
		var angle = randf() * TAU
		var distance = randf() * spawn_radius
		var star_pos = Vector2(cos(angle), sin(angle)) * distance
		stars.append(star_pos)

func _process(_delta):
	# Update camera reference
	if camera == null:
		camera = get_tree().root.get_camera_2d()
	
	# Redraw stars based on camera position
	queue_redraw()
	
	# Regenerate stars if player goes too far
	if camera != null:
		var player_distance = camera.global_position.distance_to(Vector2.ZERO)
		if player_distance > spawn_radius * 0.7:
			_generate_stars()

func _draw():
	if camera == null:
		return
	
	# Apply parallax effect to camera position
	var parallax_offset = camera.global_position * parallax_depth
	
	for star_pos in stars:
		# Offset stars by camera position with parallax
		var screen_pos = star_pos - parallax_offset
		
		# Only draw stars that are reasonably close to screen
		var screen_center = get_viewport().get_visible_rect().size / 2
		var distance_to_screen = screen_pos.distance_to(screen_center)
		
		if distance_to_screen < 2000:
			draw_circle(screen_pos, 1.0, Color.WHITE)
