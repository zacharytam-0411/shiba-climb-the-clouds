extends Control

var buttons := []
var selected_index := 0
@export var english_font_file: FontFile
@export var japanese_font_file: FontFile

func _ready() -> void:
	TranslationServer.set_locale(Global.game_lang)
	Global.update_fonts(self)
	buttons = [
		$VBoxContainer/StartButton,
		$VBoxContainer/SettingsButton,
		$VBoxContainer/ShopButton,
		$VBoxContainer/ExitButton
	]
	highlight_selected()  # Focus StartButton by default

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("action_p"):
		var new_locale := "jp" if TranslationServer.get_locale() == "en" else "en"
		Global.game_lang = new_locale
		TranslationServer.set_locale(new_locale)
		Global.update_fonts(self)
	elif Input.is_action_just_pressed("move_down"):
		selected_index = (selected_index + 1) % buttons.size()
		highlight_selected()
	elif Input.is_action_just_pressed("move_up"):
		selected_index = (selected_index - 1 + buttons.size()) % buttons.size()
		highlight_selected()
	elif Input.is_action_just_pressed("confirm_selection"):
		activate_selected()

func highlight_selected() -> void:
	if buttons[selected_index]:
		buttons[selected_index].grab_focus()

func activate_selected() -> void:
	match selected_index:
		0: _on_start_pressed()
		1: _on_settings_pressed()
		2: _on_shop_pressed()
		3: _on_exit_pressed()

func _on_start_pressed() -> void:
	print("Go to gamemode selection")
	if Global.tutorial_completed == true:
		get_tree().change_scene_to_file("res://scenes/gamemode_selection.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/tutorial.tscn")

func _on_settings_pressed() -> void:
	print("Settings Pressed")
	get_tree().change_scene_to_file("res://scenes/SettingsMenu.tscn")

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/rickroll.tscn")

func _on_shop_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/nature_shop.tscn")
