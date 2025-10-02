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
	minus_sfx_button.pressed.connect(_decrease_sfx_volume)
	plus_sfx_button.pressed.connect(_increase_sfx_volume)


	var sfxdb = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
	sfx_volume = db_to_linear(sfxdb)
	_update_sfx_volume_label()




# -- show/hide (instant) --
func show_menu() -> void:
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
	
func _decrease_sfx_volume() -> void:
	sfx_volume = clamp(sfx_volume - 0.05, 0.0, 1.0) 
	_apply_sfx_volume()
	

func _increase_sfx_volume() -> void:
	sfx_volume = clamp(sfx_volume + 0.05, 0.0, 1.0)
	_apply_sfx_volume()

func _apply_sfx_volume() -> void:
	var sfxdb = linear_to_db(sfx_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), sfxdb)
	_update_sfx_volume_label()
	
func _update_sfx_volume_label() -> void:
	var percent = int(round(sfx_volume * 100))
	sfx_volume_label.text = "%d%%" % percent


# -- buttons --
func _on_resume_pressed() -> void:
	# Hide menu, then unpause
	hide_menu()
	get_tree().paused = false

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_screen.tscn")
