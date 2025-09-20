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
	# Place directly at respawn point
	player.global_position = dest_point.global_position

	# Reset vertical + horizontal velocity
	if "velocity" in player:
		player.velocity = Vector2.ZERO

	# Force physics update so player is considered "grounded"
	if player.has_method("move_and_slide"):
		player.move_and_slide()
