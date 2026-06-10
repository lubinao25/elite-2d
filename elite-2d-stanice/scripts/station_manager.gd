extends Node

var stations: Array = []

func _ready():
	add_to_group("station_manager")

func register_station(station):
	if station not in stations:
		stations.append(station)
		station.add_to_group("stations")
		print("DEBUG: Registered station: %s (Total: %d)" % [station.station_name, stations.size()])

func get_all_stations() -> Array:
	return stations

func get_nearest_station(position: Vector2) -> Node:
	var nearest = null
	var min_distance = INF

	for station in stations:
		var distance = position.distance_to(station.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest = station

	return nearest

func get_station_by_name(station_name: String):
	for station in stations:
		if station.station_name == station_name:
			return station
	return null
