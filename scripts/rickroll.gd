extends Node2D

@onready var button: Button = $CanvasLayer/Button

func _ready():
	hide_button_temporarily()

func hide_button_temporarily():
	button.hide()
	await get_tree().create_timer(30.0).timeout
	button.show()

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_screen.tscn")
