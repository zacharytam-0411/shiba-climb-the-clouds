extends Control

@onready var preview_sprite = $PreviewPanel/PreviewSprite
@onready var name_label = $PreviewPanel/NameLabel
@onready var stats_label = $PreviewPanel/StatsLabel
@onready var p1_icon = $PlayerSlots/P1Slot/SelectedIcon
@onready var p2_icon = $PlayerSlots/P2Slot/SelectedIcon
@onready var start_button: Button = $StartButton
@onready var back_button: Button = $BackButton
@onready var selector_frame = $SelectorFrame
@onready var character_grid = $CharacterGrid

var grid_columns := 3  
var current_index := 0
var confirmed_players = {
	"P1": false,
	"P2": false
}


var selected_characters = {
	"P1": "",
	"P2": ""
}

var current_player = "P1"

func _ready():
	start_button.pressed.connect(_on_StartButton_pressed)
	back_button.pressed.connect(_on_BackButton_pressed)

	for button in character_grid.get_children():
		button.connect("pressed", Callable(self, "_on_character_selected").bind(button.name))

	_update_selector_position()
func _on_character_selected(character_name: String):
	selected_characters[current_player] = character_name
	_update_preview(character_name)
	_update_player_slot(current_player, character_name)
	current_player = "P2" if current_player == "P1" else "P1"


func _update_preview(character_name: String):
	match character_name:
		"KuroButton":
			preview_sprite.frames = preload("res://assets/sprites/skinframes/kuro_frames.tres")
			name_label.text = "Kuro"
			stats_label.text = "Balanced.\nGood all-around."

		"ShibaButton":
			preview_sprite.frames = preload("res://assets/sprites/skinframes/shiba_frames.tres")
			name_label.text = "Shiba"
			stats_label.text = "Fast and agile."
		"KnightButton":
			preview_sprite.frames = preload("res://assets/sprites/skinframes/knight_frames.tres")
			name_label.text = "Knight"
			stats_label.text = "Strong and Trustworthy."
		"LokiButton":
			preview_sprite.frames = preload("res://assets/sprites/skinframes/loki_frames.tres")
			name_label.text = "Loki"
			stats_label.text = "A good \ncompanion of Kuro."
		"MonoButton":
			preview_sprite.frames = preload("res://assets/sprites/skinframes/mono_frames.tres")
			name_label.text = "Mono"
			stats_label.text = "A good \nfriend of Kuro."
		# _:
			#preview_sprite.frames = null
			#name_label.text = "None"
			#stats_label.text = ""

	preview_sprite.play("default")

func _update_player_slot(player: String, character_name: String):
	var icon_path = "res://assets/sprites/%s_icon.png" % character_name.replace("Button", "").to_lower()
	var texture = load(icon_path)
	if player == "P1":
		p1_icon.texture = texture
	else:
		p2_icon.texture = texture

func _on_StartButton_pressed():
	Global.selected_players = selected_characters
	get_tree().change_scene_to_file("res://scenes/gamemode_selection.tscn")

func _on_BackButton_pressed():
	get_tree().change_scene_to_file("res://scenes/main_screen.tscn")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("move_right"):
		_move_selector(1)
	elif Input.is_action_just_pressed("move_left"):
		_move_selector(-1)
	elif Input.is_action_just_pressed("move_down"):
		_move_selector(grid_columns)
	elif Input.is_action_just_pressed("move_up"):
		_move_selector(-grid_columns)
	elif Input.is_action_just_pressed("confirm_selection"):
		_confirm_selection()
	elif Input.is_action_just_pressed("unconfirm_selection"):
		_unconfirm_selection()

func _move_selector(offset: int):
	var total := character_grid.get_child_count()
	current_index = clamp(current_index + offset, 0, total - 1)
	_update_selector_position()

func _update_selector_position():
	var target := character_grid.get_child(current_index)
	selector_frame.global_position = target.global_position

func _confirm_selection():
	var selected_button := character_grid.get_child(current_index)
	var character_name := selected_button.name

	selected_characters[current_player] = character_name
	_update_preview(character_name)
	_update_player_slot(current_player, character_name)
	confirmed_players[current_player] = true

	if current_player == "P1":
		current_player = "P2"
		current_index = 0
		_update_selector_position()
	else:
		Global.selected_players = {
			"P1": selected_characters["P1"].replace("Button", "").to_lower(),
			"P2": selected_characters["P2"].replace("Button", "").to_lower()
		}
		get_tree().change_scene_to_file("res://scenes/gamemode_selection.tscn")

func _unconfirm_selection():
	if current_player == "P2":
		confirmed_players["P2"] = false
		selected_characters["P2"] = ""
		_update_player_slot("P2", "")
		current_player = "P1"
		current_index = 0
		_update_selector_position()
