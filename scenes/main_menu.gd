extends Control

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
