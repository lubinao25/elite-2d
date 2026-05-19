extends CharacterBody2D

const SPEED = 200

func _physics_process(delta):
	var directions = Input.get_vector("left", "right", "up", "down")
	
	velocity = directions * SPEED
	
	move_and_slide()
