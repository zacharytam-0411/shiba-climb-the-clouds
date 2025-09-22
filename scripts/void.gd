extends Area2D

signal player_died(player: Node)

@onready var dest_point: Node2D = $DestinationPoint

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		Global.deaths += 1
		_do_respawn(body)
		player_died.emit(body)

func _do_respawn(player: Node) -> void:
	var target_pos: Vector2

	# Prefer the player's checkpoint position if set
	if "respawn_position" in player and player.respawn_position != Vector2.ZERO:
		target_pos = player.respawn_position
	else:
		# Fallback to default void respawn point
		target_pos = dest_point.global_position

	player.global_position = target_pos

	# Reset velocity
	if "velocity" in player:
		player.velocity = Vector2.ZERO

	# Force physics update so they're considered grounded
	if player.has_method("move_and_slide"):
		player.move_and_slide()
