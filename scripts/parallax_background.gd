extends ParallaxBackground

@export var scale_factor: float = 0.2   # shrink world to fit minimap
@export var follow_target: NodePath     # drag your Player node here in Inspector

var player: Node2D

func _ready() -> void:
	if follow_target != NodePath():
		player = get_node(follow_target)

func _process(delta: float) -> void:
	if player:
		# Keep background in sync with player, but scaled down
		scroll_offset = player.global_position * scale_factor
