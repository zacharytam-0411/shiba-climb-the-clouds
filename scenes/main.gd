extends Node

@onready var options_menu: CanvasLayer = $OptionsMenu

func _ready() -> void:
	TranslationServer.set_locale(Global.game_lang)
	Global.update_fonts(self)
	options_menu.visible = false
	$Player.player_id = "P1"  # or whatever ID is appropriate
	$Player.initialize_player()


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

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("action_p"):
		var new_locale := "jp" if TranslationServer.get_locale() == "en" else "en"
		Global.game_lang = new_locale
		TranslationServer.set_locale(new_locale)
