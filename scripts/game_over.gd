extends Control

func _on_quit_button_pressed() -> void:
	Global.save_progress()
	get_tree().change_scene_to_file("res://scenes/main_screen.tscn")
