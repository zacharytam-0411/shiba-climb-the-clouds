extends Control

func _on_start_pressed() -> void:
	print("Start button pressed")
	Global._reset()
	if Global.tutorial_completed == true:
		get_tree().change_scene_to_file("res://scenes/main_game.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/tutorial.tscn")

func _on_settings_pressed() -> void:
	print("Settings Pressed")
	get_tree().change_scene_to_file("res://scenes/SettingsMenu.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
