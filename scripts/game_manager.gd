extends Node

func _ready():
	# Scene setup is handled by Godot editor for tscn files
	pass

func _input(event):
	# Allow ESC to return to menu
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file("res://scenes/Menu.tscn")
