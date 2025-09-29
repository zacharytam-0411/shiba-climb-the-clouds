extends Node2D

@export var platform_scene: PackedScene
@export var player_path: NodePath
@export var vertical_spacing := 300
@export var horizontal_range := 100
@export var spawn_buffer := 600
@export var base_spacing := 50  # Easy at the start
@export var spacing_growth := 0.02
@export var coin_scene: PackedScene
@export var coin_chance := 0.4  # 40% chance to spawn a coin

var death_threshold := 800
var player: Node2D
var last_spawn_y := 0.0
var death_cooldown: float = 0.0

func _ready():
	player = get_node(player_path)
	last_spawn_y = player.global_position.y
	spawn_platforms()

func _process(_delta):
	if death_cooldown > 0.0:
		death_cooldown -= _delta

	while last_spawn_y - player.global_position.y > spawn_buffer:
		spawn_platforms()
		last_spawn_y -= spawn_buffer

	if player.is_respawning or death_cooldown > 0.0:
		return

	if player.global_position.y > last_spawn_y + death_threshold:
		await _handle_player_fall()

func spawn_platforms():
	var climb_height: float = abs(player.global_position.y)
	var spacing: float = clamp(base_spacing + climb_height * spacing_growth, base_spacing, 300)
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

		if randf() < coin_chance:
			var coin = coin_scene.instantiate()
			coin.global_position = platform.global_position + Vector2(0, -20)
			add_child(coin)

func find_nearest_platform() -> Node2D:
	var nearest_platform :StaticBody2D = null
	var nearest_distance := INF

	for platform in get_tree().get_nodes_in_group("platform"):
		var dist := player.global_position.distance_to(platform.global_position)
		if dist < nearest_distance:
			nearest_distance = dist
			nearest_platform = platform

	return nearest_platform

func _handle_player_fall() -> void:
	player.is_respawning = true
	death_cooldown = 2.0
	player.velocity = Vector2.ZERO
	player.lose_life()

	var target := find_nearest_platform()
	if target:
		player.global_position = target.global_position + Vector2(-10, -60)
	else:
		var safe_y: float = last_spawn_y - 300
		player.global_position = Vector2(player.global_position.x, safe_y)

	var overlay := get_tree().current_scene.get_node_or_null("DeathOverlay")
	if overlay:
		overlay.start_reveal(player.global_position)

	await get_tree().create_timer(0.1).timeout

	player.respawn()

	if overlay:
		overlay.reveal_circle(player.global_position)

	await get_tree().create_timer(1.0).timeout

	player.is_respawning = false
