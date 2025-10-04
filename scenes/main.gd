extends Node

@onready var options_menu: CanvasLayer = $OptionsMenu

func _ready() -> void:
	options_menu.visible = false
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):  # ESC key
		_toggle_options_menu()

func _toggle_options_menu() -> void:
	if options_menu.visible:
		options_menu.visible = false
		get_tree().paused = false
	else:
		options_menu.visible = true
		get_tree().paused = true
