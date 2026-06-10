extends Node2D

@onready var color_rect = $ColorRect
var camera: Camera2D

func _ready():
	pass

func _process(_delta):
	if camera == null:
		camera = get_tree().root.get_camera_2d()
		if camera == null:
			return

	var cam_pos = camera.global_position
	var rect_size = color_rect.get_rect().size

	color_rect.position = cam_pos - rect_size / 2
