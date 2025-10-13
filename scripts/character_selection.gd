extends Control

@onready var preview_sprite = $PreviewPanel/PreviewSprite
@onready var name_label = $PreviewPanel/NameLabel
@onready var stats_label = $PreviewPanel/StatsLabel
@onready var p1_icon = $PlayerSlots/P1Slot/SelectedIcon
@onready var p2_icon = $PlayerSlots/P2Slot/SelectedIcon
@onready var start_button: Button = $StartButton
@onready var back_button: Button = $BackButton

var selected_characters = {
	"P1": "",
	"P2": ""
}

var current_player = "P1"

func _ready():
	start_button.pressed.connect(_on_StartButton_pressed)
	back_button.pressed.connect(_on_BackButton_pressed)
	for button in $CharacterGrid.get_children():
		button.connect("pressed", Callable(self, "_on_character_selected").bind(button.name))

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
			stats_label.text = "Strong but slower."
		_:
			preview_sprite.frames = null
			name_label.text = "None"
			stats_label.text = ""

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
