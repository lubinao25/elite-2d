class_name Mission
extends Resource

var id: String
var mission_type: String = "cargo_transport"
var source_station: String
var destination_station: String
var reward: float = 100.0
var cargo_type: String = "generic"
var cargo_amount: float = 50.0
var is_active: bool = false
var is_completed: bool = false

func _init(p_id: String = "", p_source: String = "", p_dest: String = "", p_reward: float = 100.0):
	id = p_id
	source_station = p_source
	destination_station = p_dest
	reward = p_reward

func get_description() -> String:
	return "Transport %s units of %s from %s to %s. Reward: %.0f cr" % [cargo_amount, cargo_type, source_station, destination_station, reward]
