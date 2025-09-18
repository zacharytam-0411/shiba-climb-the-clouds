extends CanvasLayer

@onready var menu_root: Control = $MenuRoot
@onready var overlay: ColorRect = $Overlay
@onready var minus_button: Button = $MenuRoot/HBoxContainer/MinusButton
@onready var plus_button: Button = $MenuRoot/HBoxContainer/PlusButton
@onready var volume_label: Label = $MenuRoot/HBoxContainer/MusicVolumeLabel
@onready var resume_button: Button = $MenuRoot/ResumeButton
@onready var quit_button: Button = $MenuRoot/QuitButton

var music_volume: float = 1.0  # 0.0 .. 1.0

func _ready() -> void:
	# Start hidden
	visible = false

	# Make the overlay block input to everything behind it
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	# Load current music bus volume and update the label
	var db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	music_volume = db_to_linear(db)
	_update_volume_label()

	# Connect signals
	minus_button.pressed.connect(_decrease_volume)
	plus_button.pressed.connect(_increase_volume)
	resume_button.pressed.connect(_on_resume_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


# -- show/hide (instant) --
func show_menu() -> void:
	# Show immediately. Caller should pause the tree AFTER calling this.
	visible = true

func hide_menu() -> void:
	visible = false


# -- volume --
func _decrease_volume() -> void:
	music_volume = clamp(music_volume - 0.05, 0.0, 1.0)  # 5% step
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


# -- buttons --
func _on_resume_pressed() -> void:
	# Hide menu, then unpause
	hide_menu()
	get_tree().paused = false

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_screen.tscn")  # corrected path
