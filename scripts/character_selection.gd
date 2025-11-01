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
@onready var label: Label = $PreviewPanel/Label

var grid_columns := 5
var current_index := 0
var current_player := "P1"
var ready_to_start := false
var p1_color := Color(0.384, 0.6, 1.0, 1.0)
var p2_color := Color(1, 0.6, 0.6)

var confirmed_players = {
	"P1": false,
	"P2": false
}

var selected_characters = {
	"P1": "",
	"P2": ""
}

func _ready():
	randomize()
	start_button.focus_mode = Control.FOCUS_NONE
	back_button.focus_mode = Control.FOCUS_NONE
	_update_selector_color()
	start_button.pressed.connect(_on_StartButton_pressed)
	back_button.pressed.connect(_on_BackButton_pressed)
	TranslationServer.set_locale(Global.game_lang)
	Global.update_fonts(self)

	for button in character_grid.get_children():
		button.connect("pressed", Callable(self, "_on_character_selected").bind(button.name))

	_update_selector_position()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("action_p"):
		var new_locale := "jp" if TranslationServer.get_locale() == "en" else "en"
		Global.game_lang = new_locale
		TranslationServer.set_locale(new_locale)
		Global.update_fonts(self)
	if Input.is_action_just_pressed("move_right"):
		_move_selector(1)
	elif Input.is_action_just_pressed("move_left"):
		_move_selector(-1)
	elif Input.is_action_just_pressed("move_down"):
		_move_selector(grid_columns)
	elif Input.is_action_just_pressed("move_up"):
		_move_selector(-grid_columns)
	elif Input.is_action_just_pressed("confirm_selection"):
		if ready_to_start:
			_start_game()
		else:
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
	_update_preview(target.name)

func _confirm_selection():
	var selected_button := character_grid.get_child(current_index)
	var character_name := selected_button.name

	if character_name == "RandomButton":
		var valid_buttons := character_grid.get_children().filter(func(b): return b.name != "RandomButton")
		if valid_buttons.size() == 0:
			return
		var random_button: Control = valid_buttons[randi() % valid_buttons.size()]
		current_index = character_grid.get_children().find(random_button)
		_update_selector_position()
		character_name = random_button.name
		_update_preview(character_name)

	selected_characters[current_player] = character_name
	_update_player_slot(current_player, character_name)
	confirmed_players[current_player] = true

	if current_player == "P1":
		current_player = "P2"
		current_index = 0
		_update_selector_position()
		_update_selector_color()
	else:
		if selected_characters["P1"] != "" and selected_characters["P2"] != "":
			ready_to_start = true
			label.text = tr("Press K again to start!")

func _unconfirm_selection():
	if confirmed_players["P2"]:
		confirmed_players["P2"] = false
		selected_characters["P2"] = ""
		_update_player_slot("P2", "")
		_update_preview("")
		ready_to_start = false
		current_player = "P2"
		label.text = ""
		_update_selector_color()
	elif confirmed_players["P1"]:
		confirmed_players["P1"] = false
		selected_characters["P1"] = ""
		_update_player_slot("P1", "")
		_update_preview("")
		ready_to_start = false
		current_player = "P1"
		label.text = ""
		_update_selector_color()

func _start_game():
	Global.selected_players = {
		"P1": selected_characters["P1"].replace("Button", "").to_lower(),
		"P2": selected_characters["P2"].replace("Button", "").to_lower()
	}
	get_tree().change_scene_to_file("res://scenes/gamemode_selection.tscn")

func _on_StartButton_pressed():
	_start_game()

func _on_BackButton_pressed():
	get_tree().change_scene_to_file("res://scenes/main_screen.tscn")

func _on_character_selected(character_name: String):
	if character_name == "RandomButton":
		var valid_buttons := character_grid.get_children().filter(func(b): return b.name != "RandomButton")
		if valid_buttons.size() == 0:
			return
		var random_button: Control = valid_buttons[randi() % valid_buttons.size()]
		current_index = character_grid.get_children().find(random_button)
		_update_selector_position()
		character_name = random_button.name

	selected_characters[current_player] = character_name
	_update_preview(character_name)
	_update_player_slot(current_player, character_name)

func _update_preview(character_name: String):
	if character_name == "":
		preview_sprite.frames = null
		name_label.text = "None"
		stats_label.text = ""
		preview_sprite.position.y = 0
		return

	if character_name == "RandomButton":
		preview_sprite.frames = null
		name_label.text = tr("name_random")
		stats_label.text = tr("desc_random")
		preview_sprite.position.y = 0
		return

	var frames: SpriteFrames = null

	match character_name:
		"KuroButton":
			frames = preload("res://assets/sprites/skinframes/kuro_frames.tres")
			name_label.text = tr("name_kuro")
			stats_label.text = tr("desc_kuro")
		"ShibaButton":
			frames = preload("res://assets/sprites/skinframes/shiba_frames.tres")
			name_label.text = tr("name_shiba")
			stats_label.text = tr("desc_shiba")
		"KnightButton":
			frames = preload("res://assets/sprites/skinframes/knight_frames.tres")
			name_label.text = tr("name_knight")
			stats_label.text = tr("desc_knight")
		"LokiButton":
			frames = preload("res://assets/sprites/skinframes/loki_frames.tres")
			name_label.text = tr("name_loki")
			stats_label.text = tr("desc_loki")
		"MonoButton":
			frames = preload("res://assets/sprites/skinframes/mono_frames.tres")
			name_label.text = tr("name_mono")
			stats_label.text = tr("desc_mono")
		"MortButton":
			frames = preload("res://assets/sprites/skinframes/mort_frames.tres")
			name_label.text = tr("name_mort")
			stats_label.text = tr("desc_mort")
		"TardButton":
			frames = preload("res://assets/sprites/skinframes/tard_frames.tres")
			name_label.text = tr("name_tard")
			stats_label.text = tr("desc_tard")
		"SenaButton":
			frames = preload("res://assets/sprites/skinframes/sena_frames.tres")
			name_label.text = tr("name_sena")
			stats_label.text = tr("desc_sena")
		"NicoButton":
			frames = preload("res://assets/sprites/skinframes/nico_frames.tres")
			name_label.text = tr("name_nico")
			stats_label.text = tr("desc_nico")
		"OlafButton":
			frames = preload("res://assets/sprites/skinframes/olaf_frames.tres")
			name_label.text = tr("name_olaf")
			stats_label.text = tr("desc_olaf")
		"AngButton":
			frames = preload("res://assets/sprites/skinframes/ang_frames.tres")
			name_label.text = tr("name_ang")
			stats_label.text = tr("desc_ang")
			if confirmed_players["P1"] or confirmed_players["P2"]:
				preview_sprite.position.y = -10
			else:
				preview_sprite.position.y = 0
		"TetoButton":
			frames = preload("res://assets/sprites/skinframes/teto_frames.tres")
			name_label.text = tr("name_teto")
			stats_label.text = tr("desc_teto")
			if confirmed_players["P1"] or confirmed_players["P2"]:
				preview_sprite.position.y = -10
			else:
				preview_sprite.position.y = 0
		_:
			name_label.text = tr("name_none")
			stats_label.text = tr("desc_none")
			preview_sprite.position.y = 0

	preview_sprite.frames = frames

	if frames and frames.has_animation("default"):
		preview_sprite.play("default")

func _update_player_slot(player: String, character_name: String):
	if character_name == null or character_name == "":
		var fallback_texture = load("res://assets/sprites/questionmark.png")
		if player == "P1":
			p1_icon.texture = fallback_texture
		else:
			p2_icon.texture = fallback_texture
		return

	var icon_path = "res://assets/sprites/%s_icon.png" % character_name.replace("Button", "").to_lower()
	var texture = load(icon_path)
	if player == "P1":
		p1_icon.texture = texture
	else:
		p2_icon.texture = texture

func _update_selector_color():
	var stylebox: StyleBoxFlat = selector_frame.get("theme_override_styles/panel")
	if stylebox and stylebox is StyleBoxFlat:
		stylebox.bg_color = p1_color if current_player == "P1" else p2_color
