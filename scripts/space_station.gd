extends Area2D

@export var station_name: String = "Space Station Alpha"


func _on_body_entered(body):
	if body.name == "Player":
		print("Player reached station: " + station_name)

func _on_area_entered(area):
	if area.name == "Player":
		print("Player near station: " + station_name)
