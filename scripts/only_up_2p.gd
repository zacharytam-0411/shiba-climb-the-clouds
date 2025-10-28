extends Node2D

const PLAYER1_SCENE = preload("res://scenes/player_1.tscn")
const PLAYER2_SCENE = preload("res://scenes/player_2.tscn")

@onready var viewport1: SubViewport = $SubViewportContainer/SubViewport
@onready var viewport2: SubViewport = $SubViewportContainer/SubViewport2
@onready var display1: TextureRect = $ViewportDisplay1
@onready var display2: TextureRect = $ViewportDisplay2
@onready var race_timer_label: Label = $CanvasLayer/RaceTimerLabel  # Make sure this Label exists in your scene

const PLATFORM_VARIANTS := [
	preload("res://scenes/Platform_Normal.tscn"),
	preload("res://scenes/Platform_Normal_2.tscn"),
	preload("res://scenes/Platform_Normal_3.tscn"),
	preload("res://scenes/Platform_Normal_4.tscn"),
	preload("res://scenes/Platform_Normal_5.tscn"),
	preload("res://scenes/Platform_Normal_6.tscn"),
	preload("res://scenes/Platform_Normal_7.tscn"),
	preload("res://scenes/Platform_Normal_8.tscn"),
	preload("res://scenes/Platform_Normal_9.tscn"),
	preload("res://scenes/Platform_Normal_10.tscn"),
	preload("res://scenes/Platform_Normal_11.tscn"),
	preload("res://scenes/Platform_Normal_12.tscn"),
	preload("res://scenes/Platform_Normal_13.tscn"),
	preload("res://scenes/Platform_Normal_14.tscn"),
	preload("res://scenes/Platform_Normal_15.tscn"),
]

var platform_data: Array = []
var race_start_time: float = 0.0
var race_active: bool = true
var player_finish_times := {}

func _ready():
	display1.texture = viewport1.get_texture()
	display2.texture = viewport2.get_texture()

	display1.position = Vector2(0, 0)
	display2.position = Vector2(600, 0)

	viewport1.size = Vector2(600, 720)
	viewport2.size = Vector2(600, 720)

	_generate_platforms()

	var starter_scene = preload("res://scenes/Platform_Normal.tscn")
	var platform_start_pos = Vector2(320, 500)

	var starter1 = starter_scene.instantiate()
	starter1.global_position = platform_start_pos
	viewport1.add_child(starter1)

	var starter2 = starter_scene.instantiate()
	starter2.global_position = platform_start_pos
	viewport2.add_child(starter2)

	await get_tree().process_frame

	var player1 = PLAYER1_SCENE.instantiate()
	player1.global_position = platform_start_pos + Vector2(0, -12)
	viewport1.add_child(player1)

	if player1.has_method("set_player_id"):
		player1.set_player_id("P1")
	if player1.has_method("initialize_player"):
		player1.initialize_player()
	if player1.has_method("set_platforms"):
		player1.set_platforms(platform_data)

	var player2 = PLAYER2_SCENE.instantiate()
	player2.global_position = platform_start_pos + Vector2(0, -12)
	viewport2.add_child(player2)

	if player2.has_method("set_player_id"):
		player2.set_player_id("P2")
	if player2.has_method("initialize_player"):
		player2.initialize_player()
	if player2.has_method("set_platforms"):
		player2.set_platforms(platform_data)

	race_start_time = Time.get_ticks_msec() / 1000.0
	race_active = true

func _process(delta: float) -> void:
	if race_active:
		var elapsed = Time.get_ticks_msec() / 1000.0 - race_start_time
		race_timer_label.text = "Time: %.2f s" % elapsed

func register_win(player_name: String) -> void:
	if player_name in player_finish_times:
		return  # Already recorded

	var elapsed = Time.get_ticks_msec() / 1000.0 - race_start_time
	player_finish_times[player_name] = elapsed
	print("%s finished in %.2f seconds" % [player_name, elapsed])

	if player_finish_times.size() == 2:
		race_active = false
		race_timer_label.text = "🏁 P1: %.2fs | P2: %.2fs" % [
			player_finish_times.get("Player1", 0.0),
			player_finish_times.get("Player2", 0.0)
		]

func _generate_platforms() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	platform_data.clear()

	var previous_x := 320.0
	var vertical_spacing := 120.0
	var horizontal_limit := 200.0

	for i in range(100):
		var y = -i * vertical_spacing
		var x_offset = rng.randf_range(-horizontal_limit, horizontal_limit)
		var x = clamp(previous_x + x_offset, 100, 540)
		previous_x = x

		var variant = PLATFORM_VARIANTS[rng.randi() % PLATFORM_VARIANTS.size()]
		platform_data.append({
			"position": Vector2(x, y),
			"scene": variant
		})
