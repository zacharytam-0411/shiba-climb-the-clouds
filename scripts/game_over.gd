extends Control

@onready var quit_button: Button = $CanvasLayer/QuitButton

func _ready() -> void:
	TranslationServer.set_locale(Global.game_lang)
	Global.update_fonts(self)

	quit_button.focus_mode = Control.FOCUS_ALL
	quit_button.grab_focus()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("action_p"):
		var new_locale := "jp" if TranslationServer.get_locale() == "en" else "en"
		Global.game_lang = new_locale
		TranslationServer.set_locale(new_locale)
		Global.update_fonts(self)

	if Input.is_action_just_pressed("confirm_selection"):
		quit_button.emit_signal("pressed")

func _on_quit_button_pressed() -> void:
	Global.save_progress()
	get_tree().change_scene_to_file("res://scenes/main_screen.tscn")
