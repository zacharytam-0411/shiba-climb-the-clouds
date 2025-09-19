extends Area2D

@onready var destPoint: Node2D = $DestinationPoint
@onready var fade_overlay: ColorRect = get_tree().current_scene.get_node("CanvasLayer/FadeOverlay")

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		Global.deaths += 1
		_respawn_player(body)

func _respawn_player(player: Node) -> void:
	if not fade_overlay:
		# Fallback: teleport instantly if fade_overlay is missing
		player.position = destPoint.position
		if "velocity" in player:
			player.velocity = Vector2.ZERO
		return

	var tween := create_tween()

	# Step 1: Fade screen to black
	tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 1), 0.5)

	# Step 2: Respawn player while screen is black
	tween.tween_callback(Callable(self, "_do_respawn").bind(player))

	# Step 3: Fade screen back to transparent
	tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 0), 0.5)

func _do_respawn(player: Node) -> void:
	player.position = destPoint.position
	if "velocity" in player:
		player.velocity = Vector2.ZERO
