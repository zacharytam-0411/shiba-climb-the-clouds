extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		Global.coin += 1
		_add_coin_message()
		queue_free()

func _add_coin_message() -> void:
	var msg_node = get_tree().get_first_node_in_group("coin_ui")
	if msg_node:
		msg_node.add_coin(1)
