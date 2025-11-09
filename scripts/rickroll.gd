extends Node2D

@onready var back_button: Button = $CanvasLayer/BackButton
@onready var quit_button: Button = $CanvasLayer/QuitGameButton
@onready var label: Label = $CanvasLayer/Label

var buttons := []
var selected_index := 0

func _ready():
	TranslationServer.set_locale(Global.game_lang)
	Global.update_fonts(self)
	update_ui_texts()

	back_button.focus_mode = Control.FOCUS_ALL
	quit_button.focus_mode = Control.FOCUS_ALL

	hide_button_temporarily()
	hide_quit_button_temporarily()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("action_p"):
		var new_locale := "jp" if TranslationServer.get_locale() == "en" else "en"
		Global.game_lang = new_locale
		TranslationServer.set_locale(new_locale)
		Global.update_fonts(self)
		update_ui_texts()

	if buttons.size() > 1:
		if Input.is_action_just_pressed("move_down"):
			selected_index = (selected_index + 1) % buttons.size()
			highlight_selected()
		elif Input.is_action_just_pressed("move_up"):
			selected_index = (selected_index - 1 + buttons.size()) % buttons.size()
			highlight_selected()

	if Input.is_action_just_pressed("confirm_selection"):
		var focused := get_viewport().gui_get_focus_owner()
		if focused and focused is Button:
			focused.emit_signal("pressed")

func hide_button_temporarily() -> void:
	back_button.hide()
	await get_tree().create_timer(30.0).timeout
	back_button.show()
	buttons.append(back_button)
	selected_index = buttons.size() - 1
	highlight_selected()

func hide_quit_button_temporarily() -> void:
	quit_button.hide()
	await get_tree().create_timer(45.0).timeout
	quit_button.show()
	buttons.append(quit_button)
	selected_index = buttons.size() - 1
	highlight_selected()

func highlight_selected() -> void:
	if buttons.size() > 0 and buttons[selected_index]:
		buttons[selected_index].grab_focus()

func update_ui_texts() -> void:
	if label:
		label.text = tr("Dont quit brother")  # Make sure this key exists in your translation files

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_screen.tscn")

func _on_quit_game_button_pressed() -> void:
	get_tree().quit()
