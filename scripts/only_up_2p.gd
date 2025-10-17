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
	display2.position = Vector2(640, 0)  # Assuming each viewport is 640px wide

	# Set viewport sizes
	viewport1.size = Vector2(640, 720)
	viewport2.size = Vector2(640, 720)

	# Generate platforms and spawn starter platforms
	var seed = 12345
	_generate_platforms(seed)
	_spawn_starter_platforms()

	# Instance players and assign platform data
	var player1_instance = PLAYER1_SCENE.instantiate()
	viewport1.add_child(player1_instance)
	var player1 = player1_instance.get_node("Player")
	player1.player_id = "P1"
	player1.set_platforms(platform_data)
	player1.global_position = Vector2(200, -480)
	

	var player2_instance = PLAYER2_SCENE.instantiate()
	viewport2.add_child(player2_instance)
	var player2 = player2_instance.get_node("Player")
	player2.player_id = "P2"
	player2.set_platforms(platform_data)
	player2.global_position = Vector2(400, -480)

func _generate_platforms(seed: int) -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed
	platform_data.clear()

	for i in range(100):
		var x = rng.randf_range(100, 500)
		var y = -i * 200
		var variant = PLATFORM_VARIANTS[rng.randi() % PLATFORM_VARIANTS.size()]
		platform_data.append({
			"position": Vector2(x, y),
			"scene": variant
		})

func _spawn_starter_platforms():
	var starter_scene = preload("res://scenes/Platform_Normal.tscn")

	var platform1 = starter_scene.instantiate()
	platform1.global_position = Vector2(200, 500)
	viewport1.add_child(platform1)

	var platform2 = starter_scene.instantiate()
	platform2.global_position = Vector2(400, 500)
	viewport2.add_child(platform2)

	print("Starter platform added to viewport1:", platform1)
	print("Starter platform added to viewport2:", platform2)
