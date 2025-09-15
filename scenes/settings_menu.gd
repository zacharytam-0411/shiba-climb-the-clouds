extends Control

@onready var back_button: Button = $BackButton
@onready var color_selector: OptionButton = $HBoxContainer/OptionButton

func _ready() -> void:
	# Fill the dropdown with dinos from Global
	color_selector.clear()
	for dino in Global.available_dinos:
		color_selector.add_item(dino.capitalize())

	# Preselect current choice
	var current_index = Global.available_dinos.find(Global.selected_dino_color)
	if current_index != -1:
		color_selector.select(current_index)

	# Connect signals
	color_selector.item_selected.connect(_on_color_selected)
	back_button.pressed.connect(_on_back_pressed)


func _on_color_selected(index: int) -> void:
	Global.selected_dino_color = Global.available_dinos[index]
	print("Selected dino: ", Global.selected_dino_color)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_screen.tscn")
