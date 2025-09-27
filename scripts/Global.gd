extends Node

var sapphire_collected: bool = false
var diamond_collected: bool = false
var ruby_collected: bool = false
var emerald_collected: bool = false
var coin: int = 0
var lives: int = 5
var max_lives: int = 5
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
var finish_time: float = 0.0
var pending_player: String = ""
var pending_time: float = -1.0

# Only dinos that show up in the settings
var available_dinos := [
	"kuro",
	"loki",
	"olaf",
	"nico",
	"sena",
	"mono",
	"cole",
	"mort"
]

# Hidden dinos, only available via "P"
var secret_dinos := [
	"knight",
	"krussy",
	"shiba",
	"shibaina"
]

func _reset() -> void:
	sapphire_collected = false
	diamond_collected = false
	ruby_collected = false
	emerald_collected = false
	coin = 0
	lives = 5
	y_level = 0
	win_level = false
	timer = 0.0
	max_height = -1
	winnable = false
	music_volume_db = 0.0
	music_muted = false
	finish_time = 0.0

func _process(_delta: float) -> void:
	if diamond_collected and ruby_collected and sapphire_collected and emerald_collected and coin >= 32:
		winnable = true
	else:
		winnable = false

func _game_over() -> void:
	call_deferred("_do_game_over")

func _do_game_over() -> void:
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
