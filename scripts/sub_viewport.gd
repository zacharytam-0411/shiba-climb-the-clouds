extends SubViewport

@export var world_map: NodePath      # your minimap TileMap
@export var player: NodePath         # your real Player node
@export var player_marker: NodePath  # the minimap marker node
@export var minimap_camera: NodePath # the Camera2D inside SubViewport

var map: TileMap
var marker: Node2D
var cam: Camera2D
var player_ref: Node2D

func _ready() -> void:
	map = get_node(world_map)
	marker = get_node(player_marker)
	cam = get_node(minimap_camera)
	player_ref = get_node(player)

	# Zoom way out so entire map fits
	cam.zoom = Vector2(0.25, 0.25)  # adjust depending on map size
	cam.make_current()

	# Center the camera on the map (optional if you want static full map)
	var map_rect = map.get_used_rect()
	var tile_size = map.tile_set.tile_size
	var world_size = map_rect.size * tile_size
	cam.position = world_size / 2


func _process(_delta: float) -> void:
	# Keep marker in sync with player
	if player_ref and marker:
		marker.global_position = player_ref.global_position
