extends Node

@export var max_enemies: int = 5
@export var spawn_distance: float = 800.0
@export var spawn_rate: float = 3.0

var enemies: Array = []
var time_since_last_spawn: float = 0.0
var enemy_scene = preload("res://scenes/EnemyShip.tscn")

func _ready():
	add_to_group("enemy_spawner")

func _process(delta):
	clean_dead_enemies()

	time_since_last_spawn += delta

	var player = get_tree().root.get_node_or_null("Game/Hrac")
	if player and enemies.size() < max_enemies and time_since_last_spawn >= spawn_rate:
		_spawn_enemy(player.global_position)
		time_since_last_spawn = 0.0

func _spawn_enemy(player_pos: Vector2):
	if not enemy_scene:
		return

	var angle = randf() * TAU
	var distance = spawn_distance + randf() * 200
	var spawn_pos = player_pos + Vector2(cos(angle), sin(angle)) * distance

	var enemy = enemy_scene.instantiate()
	var game_scene = get_tree().root.get_node_or_null("Game")
	if game_scene:
		game_scene.add_child(enemy)
		enemy.global_position = spawn_pos
		enemies.append(enemy)

func clean_dead_enemies():
	enemies = enemies.filter(func(enemy): return is_instance_valid(enemy))

func get_enemy_count() -> int:
	return enemies.size()
