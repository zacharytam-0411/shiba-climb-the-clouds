extends Node

@onready var options_menu: CanvasLayer = $OptionsMenu  # your OptionsMenu.tscn instance

func _ready() -> void:
	options_menu.visible = false  # hidden at start

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):  # default = Esc
		_toggle_options_menu()


func _toggle_options_menu() -> void:
	if options_menu.visible:
		# Closing options
		options_menu.visible = false
		get_tree().paused = false
	else:
		# Opening options
		options_menu.visible = true
		get_tree().paused = true
