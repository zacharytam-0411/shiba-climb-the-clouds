extends Control

@onready var prev_button: Button = $HBoxContainer/PrevButton
@onready var next_button: Button = $HBoxContainer/NextButton
@onready var dino_name_label: Label = $HBoxContainer/DinoNameLabel
@onready var dino_preview: AnimatedSprite2D = $DinoPreview
@onready var back_button: Button = $BackButton
@onready var music_volume: HSlider = $MusicVolume
@onready var mute_check: CheckBox = $MuteCheck

var current_index: int = 0

func _ready() -> void:
	# --- Dino setup ---
	current_index = Global.available_dinos.find(Global.selected_dino_color)
	if current_index == -1:
		current_index = 0

	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)
	back_button.pressed.connect(_on_back_pressed)

	_update_preview()

	# --- Music setup ---
	var music_bus = AudioServer.get_bus_index("Music")

	# Apply stored values (already exist in Global.gd)
	AudioServer.set_bus_volume_db(music_bus, Global.music_volume_db)
	music_volume.value = db_to_slider(Global.music_volume_db)

	AudioServer.set_bus_mute(music_bus, Global.music_muted)
	mute_check.button_pressed = Global.music_muted

	# Connect signals
	music_volume.value_changed.connect(_on_music_volume_changed)
	mute_check.toggled.connect(_on_music_mute_toggled)


# --- Dino Selection ---
func _on_prev_pressed() -> void:
	current_index = (current_index - 1 + Global.available_dinos.size()) % Global.available_dinos.size()
	_update_preview()

func _on_next_pressed() -> void:
	current_index = (current_index + 1) % Global.available_dinos.size()
	_update_preview()

func _on_back_pressed() -> void:
	Global.selected_dino_color = Global.available_dinos[current_index]
	get_tree().change_scene_to_file("res://scenes/main_screen.tscn")

func _update_preview() -> void:
	var dino = Global.available_dinos[current_index]
	dino_name_label.text = dino.capitalize()
	Global.selected_dino_color = dino

	var base_path = "res://assets/sprites/dinos/male/%s/base/" % dino
	var idle_path = base_path + "idle.png"

	if ResourceLoader.exists(idle_path):
		var tex = load(idle_path)
		var frame_size = tex.get_height()
		var frame_count = tex.get_width() / frame_size

		var frames = SpriteFrames.new()
		frames.add_animation("idle")

		for i in range(int(frame_count)):
			var region = Rect2(i * frame_size, 0, frame_size, frame_size)
			var atlas = AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = region
			frames.add_frame("idle", atlas)

		dino_preview.frames = frames
		dino_preview.play("idle")


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
	# Slider value assumed 0..100
	if value <= 0:
		return -80.0 # silence
	return lerp(-30.0, 0.0, value / 100.0) # between -30 dB and 0 dB

func db_to_slider(db_value: float) -> float:
	# Map dB back to slider (inverse of above)
	return clampf(inverse_lerp(-30.0, 0.0, db_value) * 100.0, 0.0, 100.0)
