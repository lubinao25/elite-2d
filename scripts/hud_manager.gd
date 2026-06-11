extends Control

@onready var fuel_label = $TopRightStats/FuelLabel
@onready var speed_label = $TopRightStats/SpeedLabel
@onready var health_label = $BottomLeftStats/HealthLabel
@onready var health_bar = $BottomLeftStats/HealthBar
@onready var shield_label = $BottomLeftStats/ShieldLabel
@onready var shield_bar = $BottomLeftStats/ShieldBar
@onready var money_label = $BottomRightStats/MoneyLabel

func _ready():
	if PlayerStats:
		PlayerStats.fuel_changed.connect(_on_fuel_changed)
		PlayerStats.speed_changed.connect(_on_speed_changed)
		PlayerStats.health_changed.connect(_on_health_changed)
		PlayerStats.shield_changed.connect(_on_shield_changed)
		PlayerStats.money_changed.connect(_on_money_changed)

		health_bar.max_value = PlayerStats.max_health
		shield_bar.max_value = PlayerStats.max_shield

func _on_fuel_changed(new_fuel: float):
	fuel_label.text = "Fuel: %.0f / %.0f" % [new_fuel, PlayerStats.max_fuel]

func _on_speed_changed(new_speed: float):
	speed_label.text = "Speed: %.0f" % new_speed

func _on_health_changed(new_health: float):
	health_label.text = "Health: %.0f / %.0f" % [new_health, PlayerStats.max_health]
	health_bar.value = new_health

func _on_shield_changed(new_shield: float):
	shield_label.text = "Shield: %.0f / %.0f" % [new_shield, PlayerStats.max_shield]
	shield_bar.value = new_shield

func _on_money_changed(new_money: float):
	money_label.text = "Money: %.0f" % new_money
