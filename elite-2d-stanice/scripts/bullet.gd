extends Area2D

var velocity: Vector2 = Vector2.ZERO
var speed: float = 500.0
var damage: float = 10.0
var owner_type: String = "player"  # "player" or "enemy"
var lifetime: float = 30.0

func _ready():
	$LifeTimer.timeout.connect(_on_lifetime_timeout)
	$LifeTimer.start(lifetime)
	area_entered.connect(_on_area_entered)

func _process(delta):
	position += velocity * speed * delta

	# Despawn if too far from origin
	if position.length() > 3000:
		queue_free()

func set_direction(direction: Vector2):
	velocity = direction.normalized()

func set_owner_type(type: String):
	owner_type = type

func _on_lifetime_timeout():
	queue_free()

func _on_area_entered(area):
	if area.name == "Hrac" and owner_type == "enemy":
		if PlayerStats:
			PlayerStats.take_damage(damage)
		queue_free()
	elif area.name.begins_with("EnemyShip") and owner_type == "player":
		if area.has_method("take_damage"):
			area.take_damage(damage)
		queue_free()
