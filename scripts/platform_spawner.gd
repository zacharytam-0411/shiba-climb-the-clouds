extends Node2D

@export var player_path: NodePath
@export var platform_scenes: Array[PackedScene] = []
@export var vertical_spacing: int = 300
@export var horizontal_range: int = 100
@export var spawn_buffer: int = 600
@export var base_spacing: float = 60.0
@export var spacing_growth: float = 0.002
@export var nature_coin_scene: PackedScene
@export var nature_coin_chance: float = 0.6

var death_threshold: float = 1000.0
var player: Node2D
var last_spawn_y: float = 0.0
var death_cooldown: float = 0.0

func _ready():
	player = get_node_or_null(player_path)
	if player == null:
		push_error("Missing player node. Check 'player_path' in the Inspector.")
		return

	last_spawn_y = player.global_position.y
	spawn_platforms()

func _process(_delta: float) -> void:
	if death_cooldown > 0.0:
		death_cooldown -= _delta

	while last_spawn_y - player.global_position.y > spawn_buffer:
		spawn_platforms()
		last_spawn_y -= spawn_buffer

	if player.is_respawning or death_cooldown > 0.0:
		return

	if player.global_position.y > last_spawn_y + death_threshold:
		_handle_player_fall()

func spawn_platforms() -> void:
	var climb_height: float = abs(player.global_position.y)
	var spacing: float = clamp(base_spacing + climb_height * spacing_growth, base_spacing, 150.0)
	var platform_count: int = clamp(10 - int(climb_height / 500.0), 5, 10)

	var start_y := player.global_position.y
	var previous_x: float = -INF

	for i in range(platform_count):
		var y := start_y - spacing * (i + 1)
		var x := player.global_position.x + randf_range(-horizontal_range, horizontal_range)

		if abs(x - previous_x) < horizontal_range * 0.4:
			x += horizontal_range * 0.5 * (1 if randf() > 0.5 else -1)

		var spawn_pos := Vector2(x, y)
		previous_x = x

		var platform_scene: PackedScene = platform_scenes.pick_random()
		var platform: Node2D = platform_scene.instantiate() as Node2D
		platform.global_position = spawn_pos
		add_child(platform)

		if randf() < nature_coin_chance:
			var nature_coin: Node2D = nature_coin_scene.instantiate() as Node2D
			nature_coin.global_position = spawn_pos + Vector2(0, -20)
			add_child(nature_coin)

func _handle_player_fall() -> void:
	player.is_respawning = true
	death_cooldown = 2.0
	player.velocity = Vector2.ZERO
	player.lose_life()

	var target_pos: Vector2 = find_nearest_platform()
	if target_pos != Vector2.ZERO:
		player.global_position = target_pos + Vector2(-10, 10)
	else:
		var safe_y: float = last_spawn_y - 300.0
		player.global_position = Vector2(player.global_position.x - 10.0, safe_y)

	var overlay: Node = get_tree().current_scene.get_node_or_null("DeathOverlay")
	if overlay:
		overlay.start_reveal(player.global_position)

	var timer: Timer = Timer.new()
	timer.wait_time = 0.1
	timer.one_shot = true
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_respawn_timer_timeout").bind(overlay))
	timer.start()

func _on_respawn_timer_timeout(overlay: Node) -> void:
	player.respawn()

	if overlay:
		overlay.reveal_circle(player.global_position)

	var timer: Timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = true
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_finish_respawn"))
	timer.start()

func _on_finish_respawn() -> void:
	player.is_respawning = false

func find_nearest_platform() -> Vector2:
	var nearest_pos: Vector2 = Vector2.ZERO
	var nearest_distance: float = INF

	for child in get_children():
		if child.name.begins_with("Cloud") and child is Node2D:
			var pos: Vector2 = (child as Node2D).global_position
			var dist: float = player.global_position.distance_to(pos)
			if dist < nearest_distance:
				nearest_distance = dist
				nearest_pos = pos

	return nearest_pos
