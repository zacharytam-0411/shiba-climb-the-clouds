extends Area2D

@export var checkpoint_id: int = 0
var activated: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and not activated:
		activated = true
		body.set_checkpoint(global_position)
		_show_active_state()

		# Get the BottomMessage label
		var msg_node = get_tree().root.get_node("main_game/CanvasLayer/BottomMessage")
		if msg_node:
			msg_node.show_message("Checkpoint activated!")

func _show_active_state() -> void:
	if has_node("Sprite2D"):
		$Sprite2D.modulate = Color.GREEN
