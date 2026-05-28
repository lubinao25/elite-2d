extends CharacterBody2D

@export var max_speed: float = 300.0
@export var acceleration: float = 500.0
@export var rotation_speed: float = 3.5
@export var friction: float = 200.0

var current_speed: float = 0.0
var direction: float = 0.0

func _process(delta):
	# Handle rotation
	if Input.is_action_pressed("left"):
		rotation += rotation_speed * delta
	if Input.is_action_pressed("right"):
		rotation -= rotation_speed * delta
	
	# Handle acceleration/deceleration
	var acceleration_input = 0.0
	if Input.is_action_pressed("up"):
		acceleration_input = 1.0
	elif Input.is_action_pressed("down"):
		acceleration_input = -1.0
	
	# Update speed
	if acceleration_input != 0.0:
		current_speed = move_toward(current_speed, max_speed * acceleration_input, acceleration * delta)
	else:
		current_speed = move_toward(current_speed, 0.0, friction * delta)
	
	# Calculate velocity in the direction the ship is facing
	var direction_vector = Vector2(sin(rotation), -cos(rotation))
	velocity = direction_vector * current_speed
	
	# Move the ship
	position += velocity * delta
