extends Camera2D

@export var player: NodePath
var player_ref: Node2D

func _ready() -> void:
	if has_node(player):
		player_ref = get_node(player)

	# Enable camera
	enabled = true

	# Zoom factor: higher values = closer zoom
	zoom = Vector2(0.2, 0.2)   # try 2, 3, 4 to see what feels right

func _process(_delta: float) -> void:
	if player_ref:
		# Always center on the player
		global_position = player_ref.global_position
