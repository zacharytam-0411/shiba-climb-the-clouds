extends Control

@onready var default_mode_button: Button = $DefaultModeButton
@onready var only_up_button: Button = $OnlyUpButton
@onready var multiplayer_button: Button = $MultiplayerButton
@onready var _2_playerlabel: Label = $"2playerlabel"
@onready var leaderboard: Button = $Leaderboard
@onready var back_button: Button = $BackButton

var buttons := []
var selected_index := 0

func _ready():
	_2_playerlabel.visible = false

	# Connect button signals
	back_button.pressed.connect(_on_BackButton_pressed)
	default_mode_button.pressed.connect(_on_default_mode_pressed)
	only_up_button.pressed.connect(_on_only_up_pressed)
	multiplayer_button.pressed.connect(_on_multiplayer_pressed)
	leaderboard.pressed.connect(_on_leaderboard_button_pressed)

	# Store buttons in visual (vertical) order
	buttons = [
		default_mode_button,
		only_up_button,
		multiplayer_button,
		leaderboard,
		back_button
	]

	selected_index = 0  # ✅ Default to Default Mode
	highlight_selected()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("move_down"):
		selected_index = (selected_index + 1) % buttons.size()
		highlight_selected()
	elif Input.is_action_just_pressed("move_up"):
		selected_index = (selected_index - 1 + buttons.size()) % buttons.size()
		highlight_selected()
	elif Input.is_action_just_pressed("confirm_selection"):
		activate_selected()
	elif Input.is_action_just_pressed("unconfirm_selection"):
		_on_BackButton_pressed()

func highlight_selected() -> void:
	if buttons[selected_index]:
		buttons[selected_index].grab_focus()

func activate_selected() -> void:
	match selected_index:
		0: _on_default_mode_pressed()
		1: _on_only_up_pressed()
		2: _on_multiplayer_pressed()
		3: _on_leaderboard_button_pressed()
		4: _on_BackButton_pressed()

func _on_default_mode_pressed():
	print("Start button pressed")
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

func _on_leaderboard_button_pressed():
	print("Go to leaderboard")
	get_tree().change_scene_to_file("res://scenes/leaderboard.tscn")

func _on_BackButton_pressed():
	print("Back to main screen")
	get_tree().change_scene_to_file("res://scenes/main_screen.tscn")
