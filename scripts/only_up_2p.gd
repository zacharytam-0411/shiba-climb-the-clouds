extends Node2D

const PLAYER1_SCENE = preload("res://scenes/player_1.tscn")
const PLAYER2_SCENE = preload("res://scenes/player_2.tscn")

@onready var viewport1 = $SubViewportContainer/SubViewport
@onready var viewport2 = $SubViewportContainer/SubViewport2
@onready var display1: TextureRect = $ViewportDisplay1
@onready var display2: TextureRect = $ViewportDisplay2

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

func _ready():
	# Assign SubViewport textures to TextureRects
	display1.texture = viewport1.get_texture()
	display2.texture = viewport2.get_texture()

	# Position TextureRects side by side
	display1.position = Vector2(0, 0)
	display2.position = Vector2(600, 0)

	# Set viewport sizes
	viewport1.size = Vector2(600, 720)
	viewport2.size = Vector2(600, 720)

	# Generate platforms with a randomized seed
	_generate_platforms()

	# Spawn starter platforms
	var starter_scene = preload("res://scenes/Platform_Normal.tscn")
	var platform1_pos = Vector2(320, 500)

	var starter1 = starter_scene.instantiate()
	starter1.global_position = platform1_pos
	viewport1.add_child(starter1)

	var starter2 = starter_scene.instantiate()
	starter2.global_position = platform1_pos
	viewport2.add_child(starter2)

	await get_tree().process_frame

	# Instance Player 1 from its own scene
	var player1_instance = PLAYER1_SCENE.instantiate()
	viewport1.add_child(player1_instance)
	player1_instance.global_position = platform1_pos + Vector2(0, -12)

	var player1 = player1_instance.get_node("Player1")
	player1.set_player_id("P1")
	player1.initialize_player()
	player1.set_platforms(platform_data)

	# Instance Player 2 from its own scene
	var player2_instance = PLAYER2_SCENE.instantiate()
	viewport2.add_child(player2_instance)
	player2_instance.global_position = platform1_pos + Vector2(0, -12)

	var player2 = player2_instance.get_node("Player2")
	player2.set_player_id("P2")
	player2.initialize_player()
	player2.set_platforms(platform_data)

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
