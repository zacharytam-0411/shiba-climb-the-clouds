extends Node2D

@export var platform_scene: PackedScene
@export var player_path: NodePath
@export var vertical_spacing := 300
@export var horizontal_range := 100
@export var spawn_buffer := 600
@export var base_spacing := 50  # Easy at the start
@export var spacing_growth := 0.02  # How fast spacing increases

var death_threshold := 800
var player: Node2D
var last_spawn_y := 0.0

func _ready():
	player = get_node(player_path)
	last_spawn_y = player.global_position.y
	spawn_platforms()

func _process(_delta):
	while last_spawn_y - player.global_position.y > spawn_buffer:
		spawn_platforms()
		last_spawn_y -= spawn_buffer

	if player.global_position.y > last_spawn_y + death_threshold:
		player.die()

func spawn_platforms():
	var climb_height: float = abs(player.global_position.y)
	var spacing: float = clamp(base_spacing + climb_height * spacing_growth, base_spacing, 300)

	# Calculate how many platforms to spawn based on height
	var platform_count: int = clamp(10 - int(climb_height / 500), 3, 10)

	for i in range(platform_count):
		var platform = platform_scene.instantiate()
		var x_offset = randf_range(-horizontal_range, horizontal_range)
		var y_offset = -spacing * (i + 1) + randf_range(-spacing * 0.3, spacing * 0.3)
		platform.global_position = Vector2(
			player.global_position.x + x_offset,
			player.global_position.y + y_offset
		)
		add_child(platform)
