extends Node2D

@export var platform_scenes: Array[PackedScene] = []
@export var vertical_spacing: float = 120.0
@export var horizontal_range: float = 100.0
@export var platforms_total: int = 100  # Total platforms for the race
@export var starter_platform_scene: PackedScene
@export var platform_scale: Vector2 = Vector2(1.5, 1.5)

var players: Array[Node2D] = []

func _ready() -> void:
	players = await _wait_for_players()

	var player1: Node2D = $"../SubViewportContainer/SubViewport/Player1"
	var player2: Node2D = $"../SubViewportContainer/SubViewport2/Player2"

	var viewport1: Viewport = player1.get_viewport()
	var viewport2: Viewport = player2.get_viewport()

	var base_y: float = min(player1.global_position.y, player2.global_position.y)

	# Spawn starter platforms directly under each player
	var starter1: Node2D = starter_platform_scene.instantiate()
	starter1.global_position = Vector2(player1.global_position.x, player1.global_position.y + 48)
	starter1.scale = platform_scale
	viewport1.add_child(starter1)

	var starter2: Node2D = starter_platform_scene.instantiate()
	starter2.global_position = Vector2(player2.global_position.x, player2.global_position.y + 48)
	starter2.scale = platform_scale
	viewport2.add_child(starter2)

	# Spawn all race platforms
	spawn_platforms_for_race(base_y)

func _wait_for_players() -> Array[Node2D]:
	while get_tree().get_nodes_in_group("player").size() < 2:
		await get_tree().create_timer(0.1).timeout

	var found_players: Array[Node2D] = []
	for node in get_tree().get_nodes_in_group("player"):
		if node is Node2D:
			found_players.append(node)
	return found_players

func spawn_platforms_for_race(base_y: float) -> void:
	var viewport1: Viewport = players[0].get_viewport()
	var viewport2: Viewport = players[1].get_viewport()

	var previous_x: float = -INF
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()

	for i in range(platforms_total):
		var y: float = base_y - vertical_spacing * (i + 1)
		var x: float = rng.randf_range(200.0, 440.0)

		if abs(x - previous_x) < horizontal_range * 0.4:
			x += horizontal_range * 0.5 * (1 if rng.randf() > 0.5 else -1)

		var spawn_pos: Vector2 = Vector2(x, y)
		previous_x = x

		var scene: PackedScene = platform_scenes[rng.randi() % platform_scenes.size()]
		if scene == null:
			continue

		var platform1: Node2D = scene.instantiate()
		var platform2: Node2D = scene.instantiate()

		platform1.global_position = spawn_pos
		platform2.global_position = spawn_pos

		platform1.scale = platform_scale
		platform2.scale = platform_scale

		viewport1.add_child(platform1)
		viewport2.add_child(platform2)
