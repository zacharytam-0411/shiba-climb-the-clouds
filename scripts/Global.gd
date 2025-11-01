extends Node

var upgrades: Dictionary = {
	"DoubleJump": false,
	"SpeedBoost": 0,
	"CoinMagnet": false,
	"Glide": false,
	"JumpBoost": 0
}
var english_font_file: FontFile = load("res://assets/fonts/m6x11.ttf")
var japanese_font_file: FontFile = load("res://assets/fonts/BestTen-CRT.otf")

var game_lang : String = "en"

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
var selected_players: Dictionary = {
	"P1": "kuro",
	"P2": "knight"
}

var music_volume_db: float = 0.0  
var music_muted: bool = false  
var tutorial_completed: bool = false
var in_tutorial: bool = true
var dialogue_active: bool = false
var finish_time: float = 0.0
var pending_player: String = ""
var pending_time: float = -1.0
var gamemode := "default"
var last_platform: StaticBody2D = null
var only_up_coins: int = 0
var winner_id: String = ""
var winner_time: float = 0.0
var loser_id: String = ""
var loser_time: float = 0.0

var finished_players: Dictionary = {}
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

var secret_dinos := [
	"knight",
	"krussy",
	"shiba",
    "shibaina"
]

func _reset() -> void:
	winner_id = ""
	winner_time = 0.0
	loser_id = ""
	loser_time = 0.0

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
	winnable = diamond_collected and ruby_collected and sapphire_collected and emerald_collected and coin >= 32

func _game_over() -> void:
	call_deferred("_do_game_over")

func _do_game_over() -> void:
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")

func _ready() -> void:
	Shibadb.save_loaded.connect(_on_save_loaded)
	await Shibadb.init_shibadb("68ea7041e0cbb00fff2934fb")
	Shibadb.load_progress()

func _on_save_loaded(saveData) -> void:
	if saveData.has("time_spent"):
		timer = float(saveData.time_spent)
	if saveData.has("max_height"):
		max_height = int(saveData.max_height)

func save_progress() -> void:
	Shibadb.save_progress({
		"playerId": "player_1",
		"time_spent": roundi(timer * 10) / 10.0,
		"max_height": max_height
	})

func update_fonts(root: Node) -> void:
	var lang := TranslationServer.get_locale()
	var font := japanese_font_file if lang == "jp" else english_font_file
	_apply_font_recursive(root, font)
	
func _apply_font_recursive(node: Node, font: Font) -> void:
	if node is Label or node is Button or node is RichTextLabel or node is CheckBox or node is OptionButton:
		node.add_theme_font_override("font", font)

	for child in node.get_children():
		_apply_font_recursive(child, font)
