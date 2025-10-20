extends Node2D

@export var platform_scenes: Array[PackedScene] = []
@export var vertical_spacing: float = 300.0
@export var horizontal_range: float = 100.0
@export var spawn_buffer: float = 600.0
@export var starter_platform_scene: PackedScene
@export var nature_coin_scene: PackedScene
@export var nature_coin_chance: float = 0.5

var last_spawn_y: float = 0.0
var players: Array[CharacterBody2D] = []

func _ready() -> void:
	await _wait_for_players()

	var player1: CharacterBody2D = players[0]
	var player2: CharacterBody2D = players[1]

	var viewport1: Viewport = player1.get_viewport()
	var viewport2: Viewport = player2.get_viewport()

	var spawn_y: float = min(player1.global_position.y, player2.global_position.y)
	last_spawn_y = spawn_y

	# Spawn starter platforms directly under each player
	var starter1: Node2D = starter_platform_scene.instantiate()
	starter1.global_position = Vector2(player1.global_position.x, player1.global_position.y + 48)
	viewport1.add_child(starter1)

	var starter2: Node2D = starter1.duplicate()
	starter2.global_position = starter1.global_position
	viewport2.add_child(starter2)

	spawn_platforms_at(last_spawn_y)

func _wait_for_players() -> void:
	while get_tree().get_nodes_in_group("player").size() < 2:
		await get_tree().create_timer(0.1).timeout
	players = get_tree().get_nodes_in_group("player").map(func(n): return n as CharacterBody2D)


func _process(delta: float) -> void:
	if players.size() < 2:
		return

	var highest_y: float = min(players[0].global_position.y, players[1].global_position.y)
	while last_spawn_y - highest_y > spawn_buffer:
		last_spawn_y -= spawn_buffer
		spawn_platforms_at(last_spawn_y)

func spawn_platforms_at(base_y: float) -> void:
	var viewport1: Viewport = players[0].get_viewport()
	var viewport2: Viewport = players[1].get_viewport()

	var previous_x: float = -INF
	var count: int = 6
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = int(base_y)  # Sync randomization across both viewports

	for i in range(count):
		var y: float = base_y - vertical_spacing * (i + 1)
		var x: float = rng.randf_range(200.0, 440.0)

		if abs(x - previous_x) < horizontal_range * 0.4:
			x += horizontal_range * 0.5 * (1 if rng.randf() > 0.5 else -1)

		var spawn_pos: Vector2 = Vector2(x, y)
		previous_x = x

		var scene: PackedScene = platform_scenes[rng.randi() % platform_scenes.size()]
		if scene == null:
			continue

		var original_platform: Node2D = scene.instantiate()
		original_platform.global_position = spawn_pos

		var platform1: Node2D = original_platform.duplicate()
		var platform2: Node2D = original_platform.duplicate()

		viewport1.add_child(platform1)
		viewport2.add_child(platform2)

		if rng.randf() < nature_coin_chance and nature_coin_scene:
			var original_coin: Node2D = nature_coin_scene.instantiate()
			original_coin.global_position = spawn_pos + Vector2(0, -20)

			var coin1: Node2D = original_coin.duplicate()
			var coin2: Node2D = original_coin.duplicate()

			viewport1.add_child(coin1)
			viewport2.add_child(coin2)
