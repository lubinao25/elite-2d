extends CharacterBody2D

@export var max_speed: float = 250.0
@export var acceleration: float = 400.0
@export var rotation_speed: float = 3.0
@export var friction: float = 150.0
@export var fire_rate: float = 1.0
@export var bullet_damage: float = 10.0
@export var max_health: float = 50.0

var current_speed: float = 0.0
var current_health: float = 50.0
var time_since_last_shot: float = 0.0
var bullet_scene = preload("res://scenes/Bullet.tscn")
var player: Node = null

func _ready():
	current_health = max_health
	player = get_tree().root.get_node_or_null("Game/Hrac")

func _process(delta):
	if not player:
		player = get_tree().root.get_node_or_null("Game/Hrac")
		return

	var direction_to_player = (player.global_position - global_position).normalized()
	var distance_to_player = global_position.distance_to(player.global_position)

	# Simple AI: approach player and shoot
	if distance_to_player > 150:
		# Rotate towards player
		var approach_target_angle = direction_to_player.angle()
		var approach_angle_diff = angle_difference(rotation, approach_target_angle)

		if abs(approach_angle_diff) > 0.1:
			rotation += sign(approach_angle_diff) * rotation_speed * delta
		else:
			current_speed = max_speed
	else:
		# Close to player - stop approaching but keep shooting
		current_speed = move_toward(current_speed, 0.0, friction * delta)

	# Always try to face player
	var player_target_angle = direction_to_player.angle()
	var player_angle_diff = angle_difference(rotation, player_target_angle)
	if abs(player_angle_diff) > 0.05:
		rotation += sign(player_angle_diff) * rotation_speed * delta

	# Update movement
	var direction_vector = Vector2(sin(rotation), -cos(rotation))
	velocity = direction_vector * current_speed
	position += velocity * delta

	# Shoot randomly
	time_since_last_shot += delta
	if distance_to_player < 600 and randf() < 0.1:
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
	bullet.set_owner_type("enemy")
	bullet.damage = bullet_damage

func take_damage(amount: float):
	current_health -= amount
	print("Enemy took %.0f damage! Health: %.0f" % [amount, current_health])
	if current_health <= 0:
		die()

func die():
	if PlayerStats:
		PlayerStats.add_money(100.0)
		print("Enemy destroyed! Earned 100 credits!")
	queue_free()

func angle_difference(a: float, b: float) -> float:
	var diff = fmod(b - a + PI, TAU) - PI
	return diff if diff >= -PI else diff + TAU
