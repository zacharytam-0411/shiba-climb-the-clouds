extends Control

@onready var name_input: LineEdit = $VBoxContainer/NameInput

func _on_start_pressed() -> void:
	print("Restart button pressed")
	get_tree().change_scene_to_file("res://scenes/defaultmode.tscn")
	Global._reset()

func _on_settings_pressed() -> void:
	print("Settings Pressed")
	get_tree().change_scene_to_file("res://scenes/SettingsMenu.tscn")
	
func _on_exit_pressed() -> void:
	var player_name = name_input.text.strip_edges()
	if player_name == "":
		player_name = "Anonymous"

	var finish_time = roundi(Global.timer * 10) / 10.0
	

	Global.pending_player = player_name
	Global.pending_time = finish_time

	get_tree().change_scene_to_file("res://scenes/leaderboard.tscn")   
