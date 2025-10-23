extends Node2D

# === CONFIGURABLE PARAMETERS ===
@export var vertical_spacing: int = 250
@export var horizontal_range: int = 100
@export var spawn_buffer: int = 400
@export var base_spacing: float = 60.0
@export var spacing_growth: float = 0.0002
@export var nature_coin_scene: PackedScene
@export var nature_coin_chance: float = 0.6
@onready var player: CharacterBody2D = $"../Player"

@export var platform_scenes: Array[PackedScene] = [
	preload("res://scenes/Platform_Normal.tscn"),
	preload("res://scenes/Platform_Normal_2.tscn"),
	preload("res://scenes/Platform_Normal_3.tscn"),
	preload("res://scenes/Platform_Normal_9.tscn"),
	preload("res://scenes/Platform_Normal_10.tscn"),
	preload("res://scenes/Platform_Normal_15.tscn"),
	preload("res://scenes/Platform_Normal_13.tscn")
]
const TIER_HEIGHT: int = 2000

# === INTERNAL STATE ===
var players: Array[Node2D] = []
var last_spawn_y: Dictionary = {}
var death_cooldown: Dictionary = {}
var next_milestone: Dictionary = {}
var last_platform_pos: Dictionary = {}  # player_id → Vector2

var milestone_messages: Array[String] = [
	"Adventure awaits...",
	"The climb intensifies...",
	"Strange winds whisper...",
	"You are not alone...",
	"Candy...yum..",
    "Space exploration? Seems fun..."
]

func _ready() -> void:
	players = []
	for node in get_tree().get_nodes_in_group("player"):
		if node is Node2D:
			players.append(node as Node2D)

	if players.is_empty():
		push_error("No players found in 'player' group.")
		return

	for player in players:
		var id: int = int(player.get("player_id"))
		last_spawn_y[id] = player.global_position.y
		death_cooldown[id] = 0.0
		next_milestone[id] = 1
		last_platform_pos[id] = Vector2.ZERO
		_generate_platforms_for(player)

func _process(delta: float) -> void:
	for player in players:
		var id: int = int(player.get("player_id"))
		var pos_y: float = player.global_position.y

		if death_cooldown[id] > 0.0:
			death_cooldown[id] -= delta

		if player.get("is_respawning") or death_cooldown[id] > 0.0:
			continue

		var distance: float = last_spawn_y[id] - pos_y
		while distance > spawn_buffer:
			_generate_platforms_for(player)
			last_spawn_y[id] -= spawn_buffer
			distance -= spawn_buffer

		if pos_y > last_spawn_y[id] + 1000.0:
			_handle_player_fall(player)

		_check_milestone(player)

func _generate_platforms_for(player: Node2D) -> void:
	var climb: float = abs(player.global_position.y)
	var spacing: float = clamp(base_spacing + climb * spacing_growth, base_spacing, 150.0)
	var count: int = clamp(10 - int(climb / 500.0), 5, 10)

	var start_y: float = player.global_position.y
	var previous_x: float = -INF

	for i in range(count):
		var y: float = start_y - spacing * (i + 1) + randf_range(-spacing * 0.2, spacing * 0.2)
		var x: float = player.global_position.x + randf_range(-horizontal_range, horizontal_range)

		if abs(x - previous_x) < horizontal_range * 0.6:
			x += horizontal_range * randf_range(0.5, 1.0) * (1 if randf() > 0.5 else -1)

		previous_x = x
		var pos: Vector2 = Vector2(x, y)

		var platform: Node2D = _get_platform_for_y(y).instantiate() as Node2D
		platform.global_position = pos
		add_child(platform)

		if randf() < nature_coin_chance:
			var coin: Node2D = nature_coin_scene.instantiate() as Node2D
			coin.global_position = pos + Vector2(0, -20)
			add_child(coin)

func _get_platform_for_y(y: float) -> PackedScene:
	var tier: int = clamp(int(abs(y) / TIER_HEIGHT), 0, platform_scenes.size() - 1)
	return platform_scenes[tier]

func set_last_platform(id: int, position: Vector2) -> void:
	last_platform_pos[id] = position	

func _handle_player_fall(player: Node2D) -> void:
	var id: int = int(player.get("player_id"))
	player.set("is_respawning", true)
	death_cooldown[id] = 2.0
	player.set("velocity", Vector2.ZERO)
	player.call("lose_life")

	var target: Vector2 = last_platform_pos.get(id, Vector2.ZERO)
	if target != Vector2.ZERO:
		player.global_position = target + Vector2(0, -10)
	else:
		player.global_position = Vector2(player.global_position.x, last_spawn_y[id] - 10)

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

func _find_nearest_platform() -> Vector2:
	var nearest: Vector2 = Vector2.ZERO
	var closest: float = INF

	for child in get_children():
		if child.name.begins_with("Cloud") and child is Node2D:
			var dist: float = (child as Node2D).global_position.length()
			if dist < closest:
				closest = dist
				nearest = child.global_position

	return nearest

func _check_milestone(player: Node2D) -> void:
	var id: int = int(player.get("player_id"))
	var level: int = next_milestone[id]
	var target: int = level * TIER_HEIGHT
	var current: int = int(player.global_position.y)

	if abs(current) >= target:
		var popup: Node = get_tree().current_scene.get_node_or_null("CanvasLayer/MilestonePopup")
		if popup:
			var msg: String = milestone_messages[min(level - 1, milestone_messages.size() - 1)]
			popup.call("show_milestone", level, abs(current), msg)
		next_milestone[id] += 1
