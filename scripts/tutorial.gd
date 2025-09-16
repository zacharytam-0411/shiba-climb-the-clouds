extends Node2D

@onready var skip_button: Button = $CanvasLayer/Button

func _ready() -> void:
	Global.in_tutorial = true
	skip_button.pressed.connect(_on_skip_pressed)

func _on_skip_pressed() -> void:
	Global.tutorial_completed = true
	Global.in_tutorial = false
	Global._reset()
	get_tree().change_scene_to_file("res://scenes/main_screen.tscn")

# Example: when tutorial is finished normally
func _on_tutorial_finished() -> void:
	Global.tutorial_completed = true
	Global.in_tutorial = false
	Global._reset()
	get_tree().change_scene_to_file("res://scenes/main_screen.tscn")
