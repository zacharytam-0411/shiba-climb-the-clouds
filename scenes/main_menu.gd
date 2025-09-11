extends Control

func _on_start_pressed() -> void:
	print("Start button pressed")
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")

func _on_settings_pressed() -> void:
	print("Settings Pressed")

func _on_exit_pressed() -> void:
	get_tree().quit()
