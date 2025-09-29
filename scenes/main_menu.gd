extends Control

func _on_start_pressed() -> void:
	print("Start button pressed")
	Global._reset()
	if Global.tutorial_completed == true:
		Global.gamemode = "default"
		get_tree().change_scene_to_file("res://scenes/defaultmode.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/tutorial.tscn")

func _on_settings_pressed() -> void:
	print("Settings Pressed")
	get_tree().change_scene_to_file("res://scenes/SettingsMenu.tscn")

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/rickroll.tscn")


func _on_only_up_button_pressed() -> void:
	Global.gamemode = "only_up"
	Global._reset()
	get_tree().change_scene_to_file("res://scenes/OnlyUpMode.tscn")
	


func _on_shop_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/nature_shop.tscn")
