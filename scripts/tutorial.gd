extends Node2D

@onready var skip_button: Button = $Button/Button
@onready var dino: AnimatedSprite2D = $CanvasLayer/AnimatedSprite2D
@onready var overlay: ColorRect = $CanvasLayer/ColorRect
@onready var panel: Panel = $CanvasLayer/Panel
@onready var text_label: Label = $CanvasLayer/Panel/Label
@onready var continue_label: Label = $CanvasLayer/Panel/ContinueLabel
@onready var player: Node = $Player
@onready var tilemap: Node = $TileMap
@onready var ruby_pickup: Area2D = $RubyPickup
@onready var sapphire_pickup: Area2D = $SapphirePickup
@onready var gem_diamond: AnimatedSprite2D = $CanvasLayer/GemDiamond
@onready var gem_ruby: AnimatedSprite2D = $CanvasLayer/GemRuby
@onready var gem_sapphire: AnimatedSprite2D = $CanvasLayer/GemSapphire
@onready var gem_emerald: AnimatedSprite2D = $CanvasLayer/GemEmerald
@onready var right_arrow: AnimatedSprite2D = $CanvasLayer/RightArrow
@onready var left_arrow: AnimatedSprite2D = $CanvasLayer/LeftArrow
@onready var up_arrow: AnimatedSprite2D = $CanvasLayer/UpArrow
@onready var down_arrow: AnimatedSprite2D = $CanvasLayer/DownArrow
@onready var w_button: AnimatedSprite2D = $CanvasLayer/WButton
@onready var d_button: AnimatedSprite2D = $CanvasLayer/DButton
@onready var s_button: AnimatedSprite2D = $CanvasLayer/SButton
@onready var a_button: AnimatedSprite2D = $CanvasLayer/AButton
@onready var p_button: AnimatedSprite2D = $CanvasLayer/PButton
@onready var space_button: AnimatedSprite2D = $CanvasLayer/SpaceButton



var dialogue_lines = [
	"Hello there! I'm your guide, Kuro!",
	"Welcome in playing 'Climb the Clouds'!",
	"I'm here to tell you about the things that you 
	need to know before you start the game!",
	"Firstly, both arrow keys and WASD are the general controls.",
	"You can also press space bar to jump and maybe, 
	just maybe, press P for a surprise! [wip]",
	"Now, let me tell you about the 4 gems you can find:",
	"Ruby lets you wall jump.",
	"Sapphire gives you a double jump.",
	"Diamond and Emerald don't grant powers (for now).",
	"Also, remember to check out the Options page 
	to customize the dino color and the music volume!",
	"After this dialogue ends, there will be a free space
	for you to explore the mechanics of the game.",
	"Click the 'Back to Menu' button on the 
	top right corner when you are done!",
	"That's all, enjoy your game, and happy climbing!"
]

var current_line = 0
var typing = false
var typing_speed := 0.03
var blink_tween: Tween
var typing_tween: Tween

func _ready() -> void:
	Global.in_tutorial = true
	skip_button.pressed.connect(_on_skip_pressed)
	player.visible = false
	tilemap.visible = false
	skip_button.visible = false
	overlay.visible = false
	panel.visible = false
	dino.visible = false
	ruby_pickup.visible = false
	sapphire_pickup.visible = false
	text_label.text = ""
	continue_label.visible = false
	_hide_all_buttons()
	_hide_all_gems()
	if ruby_pickup:
		ruby_pickup.body_entered.connect(_on_ruby_pickup)
	if sapphire_pickup:
		sapphire_pickup.body_entered.connect(_on_sapphire_pickup)
	start_dialogue()

func start_dialogue():
	Global.dialogue_active = true
	overlay.visible = true
	overlay.color = Color(0.477, 0.918, 0.887, 0.5)
	dino.visible = true
	dino.scale = Vector2(10, 10)  
	dino.play("default")
	panel.visible = true
	text_label.visible = true
	text_label.text = ""
	current_line = 0
	_show_line()

func _show_line():
	if current_line < dialogue_lines.size():
		typing = true
		text_label.text = ""
		_hide_continue_prompt()
		if typing_tween:
			typing_tween.kill()
		_type_text(dialogue_lines[current_line])
		match current_line:
			3:
				_hide_all_buttons()
				down_arrow.visible = true
				up_arrow.visible = true
				right_arrow.visible = true
				left_arrow.visible = true	
				w_button.visible = true
				a_button.visible = true
				s_button.visible = true
				d_button.visible = true
			4:
				_hide_all_buttons()
				p_button.visible = true
				space_button.visible = true
			5:
				_hide_all_buttons()
				gem_diamond.visible = true
				gem_emerald.visible = true
				gem_ruby.visible = true
				gem_sapphire.visible = true
			6:
				_hide_all_gems()
				gem_ruby.visible = true
			7:
				_hide_all_gems()
				gem_sapphire.visible = true
			8:
				_hide_all_gems()
				gem_diamond.visible = true
				gem_emerald.visible = true
			11:
				skip_button.visible = true
			_:
				_hide_all_gems()
				skip_button.visible = false
	else:
		_end_dialogue()

func _type_text(line: String) -> void:
	if line.is_empty():
		_finish_typing()
		return
	if typing_tween:
		typing_tween.kill()
	typing_tween = create_tween()
	for i in range(line.length() + 1):
		typing_tween.tween_callback(Callable(self, "_set_text_step").bind(line.substr(0, i)))
		typing_tween.tween_interval(typing_speed)
	typing_tween.tween_callback(Callable(self, "_finish_typing"))

func _set_text_step(text: String):
	text_label.text = text

func _finish_typing():
	typing = false
	_show_continue_prompt()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if typing:
			if typing_tween:
				typing_tween.kill()
			text_label.text = dialogue_lines[current_line]
			typing = false
			_show_continue_prompt()
		else:
			_hide_continue_prompt()
			current_line += 1
			_show_line()

func _show_continue_prompt():
	continue_label.visible = true
	if blink_tween:
		blink_tween.kill()
	blink_tween = create_tween().set_loops()
	blink_tween.tween_property(continue_label, "modulate:a", 0.2, 0.5)
	blink_tween.tween_property(continue_label, "modulate:a", 1.0, 0.5)

func _hide_continue_prompt():
	continue_label.visible = false
	if blink_tween:
		blink_tween.kill()

func _end_dialogue():
	overlay.visible = false
	dino.visible = false
	panel.visible = false
	_hide_continue_prompt()
	_hide_all_gems()
	Global.dialogue_active = false
	skip_button.visible = true
	player.visible = true
	tilemap.visible = true
	if sapphire_pickup:
		sapphire_pickup.visible = true
	if ruby_pickup:
		ruby_pickup.visible = true

func _on_skip_pressed() -> void:
	Global.tutorial_completed = true
	Global.in_tutorial = false
	Global._reset()
	get_tree().change_scene_to_file("res://scenes/main_screen.tscn")

func _hide_all_gems():
	gem_diamond.visible = false
	gem_ruby.visible = false
	gem_sapphire.visible = false
	gem_emerald.visible = false

func _hide_all_buttons():
	down_arrow.visible = false
	up_arrow.visible = false
	right_arrow.visible = false
	left_arrow.visible = false
	a_button.visible = false
	w_button.visible = false
	s_button.visible = false
	d_button.visible = false
	p_button.visible = false
	space_button.visible = false

func _on_ruby_pickup(body: Node) -> void:
	if body == player:
		Global.ruby_collected = true
		ruby_pickup.queue_free()
		print("Ruby collected!")
		
func _on_sapphire_pickup(body: Node) -> void:
	if body == player:
		Global.sapphire_collected = true
		sapphire_pickup.queue_free()
		print("Sapphire collected!")
