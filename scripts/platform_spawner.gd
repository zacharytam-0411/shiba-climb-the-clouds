extends Node2D

@export var vertical_spacing: int = 250
@export var horizontal_range: int = 100
@export var spawn_buffer: int = 500
@export var base_spacing: float = 60.0
@export var spacing_growth: float = 0.0002
@export var nature_coin_scene: PackedScene
@export var nature_coin_chance: float = 0.6
@onready var player: CharacterBody2D = $"../Player"

@export var platform_tiers: Array[Dictionary] = [
	{ "min_y": 0, "max_y": -2000, "scene": preload("res://scenes/Platform_Normal.tscn") },
	{ "min_y": -2000, "max_y": -4000, "scene": preload("res://scenes/Platform_Normal_2.tscn") },
	{ "min_y": -4000, "max_y": -6000, "scene": preload("res://scenes/Platform_Normal_3.tscn") },
	{ "min_y": -6000, "max_y": -8000, "scene": preload("res://scenes/Platform_Normal_5.tscn") },
	{ "min_y": -8000, "max_y": -10000, "scene": preload("res://scenes/Platform_Normal_6.tscn") },
]

var death_threshold: float = 1000.0
var last_spawn_y: Dictionary = {}  # player_id → float
var death_cooldown: Dictionary = {}  # player_id → float
var next_milestone: Dictionary = {}  # player_id → int

var milestone_messages: Array[String] = [
	"Adventure awaits...",
	"The climb intensifies...",
	"Strange winds whisper...",
	"You are not alone...",
	"Candy...yum..",
	"Space exploration? Seems fun..."
]

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		push_error("No players found in 'player' group.")
		return

	for player in players:
		var id = player.get("player_id")
		last_spawn_y[id] = player.global_position.y
		death_cooldown[id] = 0.0
		next_milestone[id] = 1
		spawn_platforms_for(player)

func _process(delta: float) -> void:
	var players = get_tree().get_nodes_in_group("player")
	for player in players:
		var id = player.get("player_id")

		if death_cooldown.get(id, 0.0) > 0.0:
			death_cooldown[id] -= delta

		var distance_to_player: float = last_spawn_y.get(id, 0.0) - player.global_position.y
		while distance_to_player > spawn_buffer:
			spawn_platforms_for(player)
			last_spawn_y[id] -= spawn_buffer
			distance_to_player -= spawn_buffer

		if player.get("is_respawning") or death_cooldown.get(id, 0.0) > 0.0:
			continue

		if player.global_position.y > last_spawn_y.get(id, 0.0) + death_threshold:
			_handle_player_fall(player)

		_check_milestone(player)

func spawn_platforms_for(player: Node2D) -> void:
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

		var platform_scene: PackedScene = get_platform_scene_for_y(y)
		var platform: Node2D = platform_scene.instantiate()
		platform.global_position = spawn_pos
		add_child(platform)

		if randf() < nature_coin_chance:
			var nature_coin: Node2D = nature_coin_scene.instantiate()
			nature_coin.global_position = spawn_pos + Vector2(0, -20)
			add_child(nature_coin)

func get_platform_scene_for_y(y: float) -> PackedScene:
	for tier in platform_tiers:
		if y <= tier["min_y"] and y > tier["max_y"]:
			return tier["scene"]
	return platform_tiers[0]["scene"]

func _handle_player_fall(player: Node2D) -> void:
	var id = player.get("player_id")
	player.set("is_respawning", true)
	death_cooldown[id] = 2.0
	player.set("velocity", Vector2.ZERO)
	player.call("lose_life")

	var target_pos: Vector2 = find_nearest_platform()
	if target_pos != Vector2.ZERO:
		player.global_position = target_pos + Vector2(-10, 10)
	else:
		var safe_y: float = last_spawn_y.get(id, 0.0) - 300.0
		player.global_position = Vector2(player.global_position.x - 10.0, safe_y)

	var overlay: Node = get_tree().current_scene.get_node_or_null("DeathOverlay")
	if overlay:
		overlay.call("start_reveal", player.global_position)

	var timer: Timer = Timer.new()
	timer.wait_time = 0.1
	timer.one_shot = true
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_respawn_timer_timeout").bind(player, overlay))
	timer.start()

func _on_respawn_timer_timeout(player: Node2D, overlay: Node) -> void:
	player.call("respawn")

	if overlay:
		overlay.call("reveal_circle", player.global_position)

	var timer: Timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = true
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_finish_respawn").bind(player))
	timer.start()

func _on_finish_respawn(player: Node2D) -> void:
	player.set("is_respawning", false)

func find_nearest_platform() -> Vector2:
	var nearest_pos: Vector2 = Vector2.ZERO
	var nearest_distance: float = INF

	for child in get_children():
		if child.name.begins_with("Cloud") and child is Node2D:
			var pos: Vector2 = (child as Node2D).global_position
			var dist: float = pos.length()
			if dist < nearest_distance:
				nearest_distance = dist
				nearest_pos = pos

	return nearest_pos

func _check_milestone(player: Node2D) -> void:
	var id = player.get("player_id")
	var level: int = next_milestone.get(id, 1)
	var milestone_height: int = level * 2000
	var current_y: int = int(player.global_position.y)

	if abs(current_y) >= milestone_height:
		var popup := get_tree().current_scene.get_node_or_null("CanvasLayer/MilestonePopup")
		if popup:
			var message := milestone_messages[min(level - 1, milestone_messages.size() - 1)]
			popup.call("show_milestone", level, abs(current_y), message)

		next_milestone[id] += 1
