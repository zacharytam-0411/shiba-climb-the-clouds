extends Node2D

@export var platform_scenes: Array[PackedScene] = []
@export var vertical_spacing: float = 300.0
@export var horizontal_range: float = 100.0
@export var spawn_buffer: float = 600.0
@export var starter_platform_scene: PackedScene
@export var nature_coin_scene: PackedScene
@export var nature_coin_chance: float = 0.5

var last_spawn_y: float = 0.0
var players: Array = []

func _ready():
	await _wait_for_players()

	var player1 = players[0]
	var player2 = players[1]

	var viewport1 = player1.get_viewport()
	var viewport2 = player2.get_viewport()

	# Use actual player spawn positions
	var spawn_y = min(player1.global_position.y, player2.global_position.y)
	last_spawn_y = spawn_y

	# Spawn starter platforms directly under each player
	var platform1 = starter_platform_scene.instantiate()
	platform1.global_position = Vector2(player1.global_position.x, player1.global_position.y + 48)
	viewport1.add_child(platform1)

	var platform2 = starter_platform_scene.instantiate()
	platform2.global_position = Vector2(player2.global_position.x, player2.global_position.y + 48)
	viewport2.add_child(platform2)

	# Spawn initial platforms above players
	spawn_platforms_at(last_spawn_y)

func _wait_for_players() -> void:
	while get_tree().get_nodes_in_group("player").size() < 2:
		await get_tree().create_timer(0.1).timeout
	players = get_tree().get_nodes_in_group("player")

func _process(delta: float) -> void:
	if players.size() < 2:
		return

	var highest_y = min(players[0].global_position.y, players[1].global_position.y)
	while last_spawn_y - highest_y > spawn_buffer:
		last_spawn_y -= spawn_buffer
		spawn_platforms_at(last_spawn_y)

func spawn_platforms_at(base_y: float) -> void:
	var viewport1 = players[0].get_viewport()
	var viewport2 = players[1].get_viewport()

	var previous_x = -INF
	var count = 6
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	for i in range(count):
		var y = base_y - vertical_spacing * (i + 1)
		var x = rng.randf_range(200, 440)

		if abs(x - previous_x) < horizontal_range * 0.4:
			x += horizontal_range * 0.5 * (1 if rng.randf() > 0.5 else -1)

		var spawn_pos = Vector2(x, y)
		previous_x = x

		var scene = platform_scenes[rng.randi() % platform_scenes.size()]
		if scene == null:
			continue

		var platform1 = scene.instantiate()
		platform1.global_position = spawn_pos
		viewport1.add_child(platform1)

		var platform2 = scene.instantiate()
		platform2.global_position = spawn_pos
		viewport2.add_child(platform2)

		if rng.randf() < nature_coin_chance and nature_coin_scene:
			var coin1 = nature_coin_scene.instantiate()
			coin1.global_position = spawn_pos + Vector2(0, -20)
			viewport1.add_child(coin1)

			var coin2 = nature_coin_scene.instantiate()
			coin2.global_position = spawn_pos + Vector2(0, -20)
			viewport2.add_child(coin2)
