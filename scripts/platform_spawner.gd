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
var death_cooldown : float = 0.0

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
		if Global.lives > 0 and "lose_life" in player and "respawn" in player:
			await _handle_player_death()



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
		if randf() < coin_chance:
			var coin = coin_scene.instantiate()
			coin.global_position = platform.global_position + Vector2(0, -20)  # slightly above platform
			add_child(coin)

func get_respawn_position() -> Vector2:
	if Global.last_platform:
		return Global.last_platform.global_position + Vector2(0, -50)
	else:
		var safe_y: float = last_spawn_y - 300
		return Vector2(player.global_position.x, safe_y)


func _handle_player_death() -> void:
	player.is_respawning = true
	death_cooldown = 2.0  # Give enough time to rise above threshold
	player.lose_life()

	var overlay := get_tree().current_scene.get_node_or_null("DeathOverlay")
	if overlay:
		overlay.start_reveal(get_respawn_position())

	await get_tree().create_timer(0.1).timeout

	player.respawn()

	if overlay:
		overlay.reveal_circle(get_respawn_position())

	await get_tree().create_timer(1.0).timeout  # Extra buffer before re-enabling death

	player.is_respawning = false
