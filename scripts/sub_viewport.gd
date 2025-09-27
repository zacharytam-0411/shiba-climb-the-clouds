extends SubViewport

@export var world_map: NodePath
@export var player: NodePath
@export var player_marker: NodePath
@export var minimap_camera: NodePath
@export var coin_marker_scene: PackedScene
@export var coin_container: NodePath
@export var gem_container: NodePath
@export var gem_marker_sapphire: PackedScene
@export var gem_marker_diamond: PackedScene
@export var gem_marker_ruby: PackedScene
@export var gem_marker_emerald: PackedScene

var map: TileMap
var marker: Node2D
var cam: Camera2D
var player_ref: Node2D

func _ready() -> void:
	map = get_node(world_map)
	marker = get_node(player_marker)
	cam = get_node(minimap_camera)
	player_ref = get_node(player)
	var coins = get_node(coin_container)

	# Zoom way out so entire map fits
	cam.zoom = Vector2(0.25, 0.25)
	cam.make_current()

	var map_rect = map.get_used_rect()
	var tile_size = map.tile_set.tile_size
	var world_size = map_rect.size * tile_size
	cam.position = world_size / 2

	# Coin markers
	for coin in coins.get_children():
		var coin_marker = coin_marker_scene.instantiate()
		coin_marker.global_position = coin.global_position
		add_child(coin_marker)
		coin.connect("coin_collected", Callable(coin_marker, "_on_coin_collected"))

	# Gem markers
	var gems = get_node(gem_container)

	for gem in gems.get_children():
		var marker_scene: PackedScene
		var signal_name: String

		match gem.name.to_lower():
			"sapphire":
				marker_scene = gem_marker_sapphire
				signal_name = "sapphire_collected"
			"diamond":
				marker_scene = gem_marker_diamond
				signal_name = "diamond_collected"
			"ruby":
				marker_scene = gem_marker_ruby
				signal_name = "ruby_collected"
			"emerald":
				marker_scene = gem_marker_emerald
				signal_name = "emerald_collected"
			_:
				marker_scene = null
				signal_name = ""

		if marker_scene != null and signal_name != "":
			var gem_marker = marker_scene.instantiate()
			gem_marker.global_position = gem.global_position
			add_child(gem_marker)

			if gem.has_signal(signal_name):
				gem.connect(signal_name, Callable(gem_marker, "_on_gem_collected"))

func _process(_delta: float) -> void:
	if player_ref and marker:
		marker.global_position = player_ref.global_position
