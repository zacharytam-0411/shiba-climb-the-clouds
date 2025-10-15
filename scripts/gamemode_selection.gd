extends Control
@onready var default_mode_button: Button = $DefaultModeButton
@onready var only_up_button: Button = $OnlyUpButton
@onready var multiplayer_button: Button = $MultiplayerButton
@onready var _2_playerlabel: Label = $"2playerlabel"
@onready var leaderboard: Button = $Leaderboard
@onready var back_button: Button = $BackButton


func _ready():
	_2_playerlabel.visible = false
	back_button.pressed.connect(_on_BackButton_pressed)
	$DefaultModeButton.pressed.connect(self._on_default_mode_pressed)
	$OnlyUpButton.pressed.connect(self._on_only_up_pressed)
	$MultiplayerButton.pressed.connect(self._on_multiplayer_pressed)
	$Leaderboard.pressed.connect(self._on_leaderboard_button_pressed)
	

func _on_default_mode_pressed():
	print("Start button pressed")
	Global._reset()
	if Global.tutorial_completed == true:
		Global.gamemode = "default"
		get_tree().change_scene_to_file("res://scenes/defaultmode.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/tutorial.tscn")

func _on_only_up_pressed():
	Global._reset()
	if Global.tutorial_completed == true:
		Global.gamemode = "only_up"
		get_tree().change_scene_to_file("res://scenes/OnlyUpMode.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/tutorial.tscn")

func _on_multiplayer_pressed():
	_2_playerlabel.visible = true
	print("Multiplayer Mode selected")
	await get_tree().create_timer(1.0).timeout
	_2_playerlabel.visible = false

func _on_leaderboard_button_pressed():
	get_tree().change_scene_to_file("res://scenes/leaderboard.tscn")

func _on_BackButton_pressed():
	get_tree().change_scene_to_file("res://scenes/main_screen.tscn")
