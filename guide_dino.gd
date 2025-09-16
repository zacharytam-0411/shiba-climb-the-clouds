extends Node2D

@onready var dino: AnimatedSprite2D = $AnimatedSprite2D
@onready var overlay: ColorRect = $ColorRect
@onready var panel: Panel = $"../CanvasLayer/Panel"
@onready var text_label: Label = $"../CanvasLayer/Panel/Label"

var tween: Tween
var dialogue_lines = [
	"Hello there! I'm your guide.",
	"Use arrow keys to move around.",
	"Press space to jump!",
	"Good luck out there!"
]
var current_line := 0
var typing := false
var typing_speed := 0.03  # seconds per character

func _ready() -> void:
	# Hide everything initially
	overlay.visible = false
	panel.visible = false
	dino.visible = false
	text_label.text = ""
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD

	# Start dialogue automatically
	start_dialogue()

func start_dialogue():
	print("Dialogue started")
	Global.dialogue_active = true

	# Show overlay, dino, and panel
	overlay.visible = true
	overlay.color = Color(0, 0, 0, 0.5)  # semi-transparent black

	dino.visible = true
	dino.scale = Vector2.ZERO  # will pop in
	if dino.has_method("play"):
		dino.play("default")  # change to your idle/talking anim name

	panel.visible = true
	panel.modulate = Color(1, 1, 1, 1)
	text_label.visible = true

	# Dino pop-in tween
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(dino, "scale", Vector2.ONE, 0.3)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

	# Start first line
	current_line = 0
	_show_line()

func _show_line():
	if current_line < dialogue_lines.size():
		typing = true
		text_label.text = ""
		_type_text(dialogue_lines[current_line])
	else:
		_end_dialogue()

func _type_text(line: String) -> void:
	if line.is_empty():
		_finish_typing()
		return

	var typing_tween = create_tween()
	for i in range(line.length() + 1):
		typing_tween.tween_callback(Callable(self, "_set_text_step")
			.bind(line.substr(0, i)))
		typing_tween.tween_interval(typing_speed)
	typing_tween.tween_callback(Callable(self, "_finish_typing"))

func _set_text_step(text: String):
	text_label.text = text

func _finish_typing():
	typing = false

func _unhandled_input(event: InputEvent) -> void:
	if not Global.dialogue_active:
		return

	if event.is_action_pressed("ui_accept"):
		if typing:
			# Instantly finish current line
			text_label.text = dialogue_lines[current_line]
			typing = false
		else:
			# Next line
			current_line += 1
			_show_line()

func _end_dialogue():
	overlay.visible = false
	dino.visible = false
	panel.visible = false
	Global.dialogue_active = false
	print("Dialogue ended")
