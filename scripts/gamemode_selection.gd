extends Control

@onready var default_mode_button: Button = $DefaultModeButton
@onready var only_up_button: Button = $OnlyUpButton
@onready var multiplayer_button: Button = $MultiplayerButton
@onready var back_button: Button = $BackButton

var buttons := []
var selected_index := 0

func _ready():
	TranslationServer.set_locale(Global.game_lang)
	Global.update_fonts(self)

	# Connect signals
	default_mode_button.pressed.connect(_on_default_mode_pressed)
	only_up_button.pressed.connect(_on_only_up_pressed)
	multiplayer_button.pressed.connect(_on_multiplayer_pressed)
	back_button.pressed.connect(_on_BackButton_pressed)

	buttons = [
		default_mode_button,
		only_up_button,
		multiplayer_button
	]

	# Enable focus mode
	for button in buttons:
		button.focus_mode = Control.FOCUS_ALL

	selected_index = 0
	highlight_selected()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("action_p"):
		var new_locale := "jp" if TranslationServer.get_locale() == "en" else "en"
		Global.game_lang = new_locale
		TranslationServer.set_locale(new_locale)
		Global.update_fonts(self)

	elif Input.is_action_just_pressed("move_right"):
		selected_index = (selected_index + 1) % buttons.size()
		highlight_selected()

	elif Input.is_action_just_pressed("move_left"):
		selected_index = (selected_index - 1 + buttons.size()) % buttons.size()
		highlight_selected()

	elif Input.is_action_just_pressed("confirm_selection"):
		var focused := get_viewport().gui_get_focus_owner()
		if focused and focused is Button:
			focused.emit_signal("pressed")

	elif Input.is_action_just_pressed("unconfirm_selection"):
		_on_BackButton_pressed()

func highlight_selected() -> void:
	buttons[selected_index].grab_focus()

# -- Button Handlers --
func _on_default_mode_pressed():
	Global._reset()
	if Global.tutorial_completed:
		Global.gamemode = "default"
		get_tree().change_scene_to_file("res://scenes/defaultmode.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/tutorial.tscn")

func _on_only_up_pressed():
	Global._reset()
	if Global.tutorial_completed:
		Global.gamemode = "only_up"
		get_tree().change_scene_to_file("res://scenes/OnlyUpMode.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/tutorial.tscn")

func _on_multiplayer_pressed():
	if Global.tutorial_completed:
		Global.gamemode = "2p"
		get_tree().change_scene_to_file("res://scenes/only_up_2p.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/tutorial.tscn")

func _on_BackButton_pressed():
	get_tree().change_scene_to_file("res://scenes/main_screen.tscn")
