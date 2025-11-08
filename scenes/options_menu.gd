extends CanvasLayer

@onready var menu_root: Control = $MenuRoot
@onready var overlay: ColorRect = $Overlay
@onready var minus_button: Button = $MenuRoot/VolumeContainer/MinusButton
@onready var plus_button: Button = $MenuRoot/VolumeContainer/PlusButton
@onready var volume_label: Label = $MenuRoot/VolumeContainer/MusicVolumeLabel
@onready var resume_button: Button = $MenuRoot/ResumeButton
@onready var quit_button: Button = $MenuRoot/QuitButton
@onready var minus_sfx_button: Button = $MenuRoot/SFXContainer/MinusSFXButton
@onready var sfx_volume_label: Label = $MenuRoot/SFXContainer/SFXVolumeLabel
@onready var plus_sfx_button: Button = $MenuRoot/SFXContainer/PlusSFXButton

var music_volume: float = 1.0 
var sfx_volume: float = 1.0 

func _ready() -> void:
	visible = false
	TranslationServer.set_locale(Global.game_lang)
	Global.update_fonts(self)

	overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	# Load current volumes
	var music_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	music_volume = db_to_linear(music_db)
	_update_volume_label()

	var sfx_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
	sfx_volume = db_to_linear(sfx_db)
	_update_sfx_volume_label()

	# Connect signals
	minus_button.pressed.connect(_decrease_volume)
	plus_button.pressed.connect(_increase_volume)
	resume_button.pressed.connect(_on_resume_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	minus_sfx_button.pressed.connect(_decrease_sfx_volume)
	plus_sfx_button.pressed.connect(_increase_sfx_volume)

	# Enable focus navigation
	for button in [
		minus_button, plus_button,
		minus_sfx_button, plus_sfx_button,
		resume_button, quit_button
	]:
		button.focus_mode = Control.FOCUS_ALL

	# Set rightward navigation
	minus_button.focus_neighbor_right = plus_button.get_path()
	plus_button.focus_neighbor_right = minus_sfx_button.get_path()
	minus_sfx_button.focus_neighbor_right = plus_sfx_button.get_path()
	plus_sfx_button.focus_neighbor_right = resume_button.get_path()
	resume_button.focus_neighbor_right = quit_button.get_path()

	# Initial focus
	minus_button.grab_focus()

func show_menu() -> void:
	visible = true
	minus_button.grab_focus()

func hide_menu() -> void:
	visible = false

# -- Music Volume --
func _decrease_volume() -> void:
	music_volume = clamp(music_volume - 0.05, 0.0, 1.0)
	_apply_volume()

func _increase_volume() -> void:
	music_volume = clamp(music_volume + 0.05, 0.0, 1.0)
	_apply_volume()

func _apply_volume() -> void:
	var db = linear_to_db(music_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db)
	_update_volume_label()

func _update_volume_label() -> void:
	var percent = int(round(music_volume * 100))
	volume_label.text = "%d%%" % percent

# -- SFX Volume --
func _decrease_sfx_volume() -> void:
	sfx_volume = clamp(sfx_volume - 0.05, 0.0, 1.0)
	_apply_sfx_volume()

func _increase_sfx_volume() -> void:
	sfx_volume = clamp(sfx_volume + 0.05, 0.0, 1.0)
	_apply_sfx_volume()

func _apply_sfx_volume() -> void:
	var db = linear_to_db(sfx_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), db)
	_update_sfx_volume_label()

func _update_sfx_volume_label() -> void:
	var percent = int(round(sfx_volume * 100))
	sfx_volume_label.text = "%d%%" % percent

# -- Buttons --
func _on_resume_pressed() -> void:
	hide_menu()
	get_tree().paused = false

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_screen.tscn")

# -- Language toggle (optional) --
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("action_p"):
		var new_locale := "jp" if TranslationServer.get_locale() == "en" else "en"
		Global.game_lang = new_locale
		TranslationServer.set_locale(new_locale)
		Global.update_fonts(self)

	if Input.is_action_just_pressed("confirm_selection"):
		var focused := get_viewport().gui_get_focus_owner()
		if focused and focused is Button:
			focused.emit_signal("pressed")


# -- Helpers --
func linear_to_db(value: float) -> float:
	if value <= 0.0:
		return -80.0
	return lerp(-30.0, 0.0, value)

func db_to_linear(db: float) -> float:
	return clampf(inverse_lerp(-30.0, 0.0, db), 0.0, 1.0)
