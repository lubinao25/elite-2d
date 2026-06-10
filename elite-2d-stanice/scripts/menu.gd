extends Control

func _ready():
	$VBoxContainer/PlayButton.pressed.connect(_on_play_button_pressed)

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
