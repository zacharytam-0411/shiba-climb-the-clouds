extends Area2D

@export var checkpoint_id: int = 0
var activated: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and not activated:
		activated = true

		if body.has_method("set_checkpoint"):
			body.set_checkpoint(global_position)

		_show_active_state()
		var msg_node = get_tree().root.get_node("DefaultMode/CanvasLayer/BottomMessage")
		if msg_node:
			msg_node.show_message("Checkpoint Activated!")

func _show_active_state() -> void:
	if has_node("Sprite2D"):
		$Sprite2D.modulate = Color.GREEN

func _show_message(text: String) -> void:
	var msg_node = get_tree().get_first_node_in_group("ui_message")
	if msg_node and msg_node.has_method("show_message"):
		msg_node.show_message(text)
