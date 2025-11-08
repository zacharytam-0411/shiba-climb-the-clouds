extends Control

@onready var back_button: Button = $BackButton
@onready var music_volume: HSlider = $MusicVolume
@onready var mute_check: CheckBox = $MuteCheck

var current_index: int = 0

func _ready() -> void:

	current_index = Global.available_dinos.find(Global.selected_dino_color)
	if current_index == -1:
		current_index = 0

	back_button.pressed.connect(_on_back_pressed)


	var music_bus = AudioServer.get_bus_index("Music")

	AudioServer.set_bus_volume_db(music_bus, Global.music_volume_db)
	music_volume.value = db_to_slider(Global.music_volume_db)

	AudioServer.set_bus_mute(music_bus, Global.music_muted)
	mute_check.button_pressed = Global.music_muted

	music_volume.value_changed.connect(_on_music_volume_changed)
	mute_check.toggled.connect(_on_music_mute_toggled)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_screen.tscn")

# --- Music Controls ---
func _on_music_volume_changed(value: float) -> void:
	var music_bus = AudioServer.get_bus_index("Music")
	var db_value = slider_to_db(value)
	AudioServer.set_bus_volume_db(music_bus, db_value)
	Global.music_volume_db = db_value

func _on_music_mute_toggled(pressed: bool) -> void:
	var music_bus = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_mute(music_bus, pressed)
	Global.music_muted = pressed

# --- Helpers ---
func slider_to_db(value: float) -> float:
	if value <= 0:
		return -80.0
	return lerp(-30.0, 0.0, value / 100.0)

func db_to_slider(db_value: float) -> float:
	return clampf(inverse_lerp(-30.0, 0.0, db_value) * 100.0, 0.0, 100.0)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("unconfirm_selection"):
		_on_back_pressed()
