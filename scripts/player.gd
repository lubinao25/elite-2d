extends CharacterBody2D

@export var max_speed: float = 300.0
@export var acceleration: float = 150.0
@export var deceleration: float = 150.0
@export var rotation_speed: float = 3.5
@export var fire_rate: float = 0.2
@export var bullet_damage: float = 10.0

var current_speed: float = 0.0
var direction: float = 0.0
var time_since_last_shot: float = 0.0
var bullet_scene = preload("res://scenes/Bullet.tscn")

func _ready():
	if PlayerStats:
		PlayerStats.update_speed(0.0)

func _process(delta):
	# Handle rotation
	if Input.is_action_pressed("left"):
		rotation += rotation_speed * delta
	if Input.is_action_pressed("right"):
		rotation -= rotation_speed * delta

	# Handle speed changes with W and S keys
	if Input.is_action_pressed("up"):
		# Accelerate forward (W key)
		current_speed = move_toward(current_speed, max_speed, acceleration * delta)
	elif Input.is_action_pressed("down"):
		# Decelerate or go in reverse (S key)
		current_speed = move_toward(current_speed, -max_speed, deceleration * delta)
	else:
		# Speed remains constant when no input
		pass

	# Consume fuel based on current speed
	if current_speed != 0.0 and PlayerStats:
		# Higher speed = higher fuel consumption
		var fuel_cost = PlayerStats.fuel_consumption_rate * delta * (abs(current_speed) / max_speed)
		if not PlayerStats.consume_fuel(fuel_cost):
			current_speed = 0.0

	# Update speed in stats
	if PlayerStats:
		PlayerStats.update_speed(abs(current_speed))

	# Calculate velocity in the direction the ship is facing
	var direction_vector = Vector2(sin(rotation), -cos(rotation))
	velocity = direction_vector * current_speed

	# Move the ship
	position += velocity * delta

	# Handle shooting
	time_since_last_shot += delta
	if Input.is_action_pressed("shoot"):
		if time_since_last_shot >= fire_rate:
			_shoot()
			time_since_last_shot = 0.0

func _shoot():
	if not bullet_scene:
		return

	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	bullet.set_direction(Vector2(sin(rotation), -cos(rotation)))
	bullet.set_owner_type("player")
	bullet.damage = bullet_damage

func take_damage(amount: float):
	if PlayerStats:
		PlayerStats.take_damage(amount)
		print("Player took %.0f damage! Health: %.0f" % [amount, PlayerStats.current_health])
