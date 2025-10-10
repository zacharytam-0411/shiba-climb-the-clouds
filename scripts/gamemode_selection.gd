extends Control
@onready var default_mode_button: Button = $DefaultModeButton
@onready var only_up_button: Button = $OnlyUpButton
@onready var multiplayer_button: Button = $MultiplayerButton


func _ready():
	$DefaultModeButton.pressed.connect(self._on_default_mode_pressed)
	$OnlyUpButton.pressed.connect(self._on_only_up_pressed)
	$MultiplayerButton.pressed.connect(self._on_multiplayer_pressed)

func _on_default_mode_pressed():
	print("Start button pressed")
	Global._reset()
	if Global.tutorial_completed == true:
		Global.gamemode = "default"
		get_tree().change_scene_to_file("res://scenes/defaultmode.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/tutorial.tscn")

func _on_only_up_pressed():
	Global.gamemode = "only_up"
	Global._reset()
	get_tree().change_scene_to_file("res://scenes/OnlyUpMode.tscn")

func _on_multiplayer_pressed():
	print("Multiplayer Mode selected")
	get_tree().change_scene("res://Scenes/MultiplayerMode.tscn")
