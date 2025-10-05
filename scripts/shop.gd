extends CanvasLayer

@onready var menu_root: Control = $MenuRoot
@onready var overlay: ColorRect = $Overlay
@onready var resume_button: Button = $MenuRoot/ResumeButton

func _ready() -> void:
	visible = false
	resume_button.pressed.connect(_on_resume_pressed)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_resume_pressed() -> void:
	get_tree().paused = false  # Unpause FIRST
	hide_menu()

func show_menu() -> void:
	visible = true
	get_tree().paused = true  # Add this

func hide_menu() -> void:
	visible = false
	get_tree().paused = false 
