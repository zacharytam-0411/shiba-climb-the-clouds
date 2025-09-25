extends Area2D

signal player_died(player: Node)

@onready var player: CharacterBody2D = $"../Player"
@onready var dest_point: Node2D = $DestinationPoint   # Fallback respawn

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player.lose_life()

		# Respawn the player safely
		_do_respawn(body)

		# Emit signal for fade overlay
		player_died.emit(body)


func _do_respawn(player: CharacterBody2D) -> void:
	var target_pos: Vector2

	# If the player has a checkpoint, use it
	if "respawn_position" in player and player.respawn_position != Vector2.ZERO:
		target_pos = player.respawn_position
	else:
		# Otherwise fallback to the Void’s DestinationPoint
		target_pos = dest_point.global_position

	# Offset so player doesn’t clip into the ground
	target_pos.y -= 16  

	player.global_position = target_pos
	player.velocity = Vector2.ZERO

	# Reset animations
	if player.has_node("AnimatedSprite2D"):
		player.get_node("AnimatedSprite2D").play("idle")
