extends Node

# HTML5 fix - create a safe wrapper
static func safe_get_process_id() -> int:
	if OS.get_name() != "HTML5":
		return OS.get_process_id()
	else:
		return randi()  # Fallback for HTML5

var sapphire_collected : bool = false
var diamond_collected : bool = false
var ruby_collected : bool = false
var emerald_collected : bool = false
var coin : int = 0
var deaths : int = 0
var y_level : int = 0
var win_level : bool = false
var timer = 0
var winnable : bool = false
var max_height : int = -1

func _reset():
	sapphire_collected = false
	diamond_collected = false
	ruby_collected = false
	emerald_collected = false
	coin = 0
	deaths = 0
	y_level = 0
	win_level = false
	timer = 0
	max_height = -1
	winnable = false
	
func _process(_delta: float) -> void:
	if diamond_collected == true and ruby_collected == true and sapphire_collected == true and coin == 25 and emerald_collected == true:
		winnable = true
