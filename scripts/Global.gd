# global.gd
extends Node

var sapphire_collected: bool = false
var diamond_collected: bool = false
var ruby_collected: bool = false
var emerald_collected: bool = false
var coin: int = 0
var deaths: int = 0
var y_level: int = 0
var win_level: bool = false
var timer: float = 0.0
var winnable: bool = false
var max_height: int = -1
var selected_dino_color: String = "kuro"
var music_volume_db: float = 0.0  
var music_muted: bool = false  
var tutorial_completed: bool = false
var in_tutorial: bool = true
var dialogue_active: bool = false
	
var available_dinos := [
	"kuro",
	"loki",
	"olaf",
	"nico",
	"sena",
	"mono",
	"cole",
	"mort",
	"knight",
	"tard"
]

func _reset() -> void:
	sapphire_collected = false
	diamond_collected = false
	ruby_collected = false
	emerald_collected = false
	coin = 0
	deaths = 0
	y_level = 0
	win_level = false
	timer = 0.0
	max_height = -1
	winnable = false
	music_volume_db = 0.0
	music_muted = false
	
	
func _process(_delta: float) -> void:
	# Make sure all win conditions are met before enabling winnable
	if diamond_collected and ruby_collected and sapphire_collected and emerald_collected and coin >= 25:
		winnable = true
	else:
		winnable = false
