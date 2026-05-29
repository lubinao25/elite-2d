extends Node

# Fuel
@export var max_fuel: float = 1000.0
var current_fuel: float = 1000.0
@export var fuel_consumption_rate: float = 50.0  # units per second of movement

# Health
@export var max_health: float = 100.0
var current_health: float = 100.0

# Shield
@export var max_shield: float = 100.0
var current_shield: float = 100.0
@export var shield_regeneration_rate: float = 20.0  # units per second when not damaged
var time_since_shield_damage: float = 0.0
@export var shield_regeneration_delay: float = 2.0  # delay before shield starts regenerating

# Money
var money: float = 1000.0

# Speed (read from player)
var current_speed: float = 0.0

# Signals for UI updates
signal fuel_changed(new_fuel: float)
signal health_changed(new_health: float)
signal shield_changed(new_shield: float)
signal money_changed(new_money: float)
signal speed_changed(new_speed: float)

# Cargo
var current_cargo: float = 0.0
var max_cargo: float = 100.0

# Missions
var active_mission: Dictionary = {}
var completed_missions: int = 0

func _ready():
	pass

func _process(delta):
	update_shield_regeneration(delta)

func consume_fuel(amount: float) -> bool:
	if current_fuel >= amount:
		current_fuel -= amount
		fuel_changed.emit(current_fuel)
		return true
	return false

func refuel(amount: float):
	current_fuel = min(current_fuel + amount, max_fuel)
	fuel_changed.emit(current_fuel)

func take_damage(amount: float):
	var damage_to_shield = min(amount, current_shield)
	current_shield -= damage_to_shield
	shield_changed.emit(current_shield)
	time_since_shield_damage = 0.0

	var remaining_damage = amount - damage_to_shield
	if remaining_damage > 0:
		current_health -= remaining_damage
		health_changed.emit(current_health)

func heal(amount: float):
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health)

func add_money(amount: float):
	money += amount
	money_changed.emit(money)

func spend_money(amount: float) -> bool:
	if money >= amount:
		money -= amount
		money_changed.emit(money)
		return true
	return false

func update_speed(speed: float):
	current_speed = speed
	speed_changed.emit(speed)

func update_shield_regeneration(delta: float):
	time_since_shield_damage += delta
	if time_since_shield_damage > shield_regeneration_delay:
		if current_shield < max_shield:
			current_shield = min(current_shield + shield_regeneration_rate * delta, max_shield)
			shield_changed.emit(current_shield)

func add_cargo(amount: float) -> bool:
	if current_cargo + amount <= max_cargo:
		current_cargo += amount
		return true
	return false

func remove_cargo(amount: float) -> bool:
	if current_cargo >= amount:
		current_cargo -= amount
		return true
	return false

func is_alive() -> bool:
	return current_health > 0
