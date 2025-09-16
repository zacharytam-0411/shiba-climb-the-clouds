extends Node2D

# --- Nodes ---
@onready var skip_button: Button = $Button/Button
@onready var dino: AnimatedSprite2D = $CanvasLayer/AnimatedSprite2D
@onready var overlay: ColorRect = $CanvasLayer/ColorRect
@onready var panel: Panel = $CanvasLayer/Panel
@onready var text_label: Label = $CanvasLayer/Panel/Label
@onready var player: Node = $Player
@onready var tilemap: Node = $TileMap

# --- Dialogue system ---
var tween: Tween
var dialogue_lines = [
	"Hello there! I'm your guide, Kuro!",
	"I'm here to tell you about the things that you need to 
	know before you start the game!",
	"Firstly, both arrow keys and WASD are the general controls.",
	"You can also press space bar to jump and maybe,
	just maybe, press p for a surprise!",
	"Thats all and, enjoy your game!"
]
var current_line = 0
var typing = false
var typing_speed := 0.03

func _ready() -> void:
	Global.in_tutorial = true
	skip_button.pressed.connect(_on_skip_pressed)

	# Hide world at first
	player.visible = false
	tilemap.visible = false

	# Hide UI
	overlay.visible = false
	panel.visible = false
	dino.visible = false
	text_label.text = ""

	# Start dialogue immediately
	start_dialogue()


# --- Start dialogue ---
func start_dialogue():
	print("Dialogue started!")
	Global.dialogue_active = true

	# Dark overlay
	overlay.visible = true
	overlay.color = Color(0, 0, 0, 0.5)

	# Dino setup
	dino.visible = true
	dino.scale = Vector2(7, 7)   # adjust as needed
	dino.play("default")

	# Dialogue panel + text
	panel.visible = true
	text_label.visible = true
	text_label.text = ""

	# Reset line counter and show first line
	current_line = 0
	_show_line()


# --- Show next line ---
func _show_line():
	if current_line < dialogue_lines.size():
		typing = true
		text_label.text = ""
		_type_text(dialogue_lines[current_line])
	else:
		_end_dialogue()


# --- Typewriter effect ---
func _type_text(line: String) -> void:
	if line.is_empty():
		_finish_typing()
		return

	var typing_tween = create_tween()
	for i in range(line.length() + 1):
		typing_tween.tween_callback(Callable(self, "_set_text_step").bind(line.substr(0, i)))
		typing_tween.tween_interval(typing_speed)
	typing_tween.tween_callback(Callable(self, "_finish_typing"))

func _set_text_step(text: String):
	text_label.text = text

func _finish_typing():
	typing = false


# --- Input to continue dialogue ---
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if typing:
			text_label.text = dialogue_lines[current_line]
			typing = false
		else:
			current_line += 1
			_show_line()


# --- End dialogue ---
func _end_dialogue():
	overlay.visible = false
	dino.visible = false
	panel.visible = false

	Global.dialogue_active = false

	# Show world after tutorial dialogue
	player.visible = true
	tilemap.visible = true


# --- Leave tutorial ---
func _on_skip_pressed() -> void:
	Global.tutorial_completed = true
	Global.in_tutorial = false
	Global._reset()
	get_tree().change_scene_to_file("res://scenes/main_screen.tscn")
