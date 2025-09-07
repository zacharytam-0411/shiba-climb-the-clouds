extends Node

var sapphire_collected : bool = false
var diamond_collected : bool = false
var ruby_collected : bool = false
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
	coin = 0
	deaths = 0
	y_level = 0
	win_level = false
	timer = 0
	
func _process(delta: float) -> void:
	if diamond_collected == true and ruby_collected == true and sapphire_collected == true and coin == 25:
		winnable = true
