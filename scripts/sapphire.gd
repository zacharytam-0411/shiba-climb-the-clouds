extends Area2D
signal sapphire_collected

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		var msg_node = get_tree().get_first_node_in_group("message_ui")
		if msg_node and Global.sapphire_collected == false:
			msg_node.show_message("Sapphire Collected!")
		Global.sapphire_collected = true
		emit_signal("sapphire_collected")
		queue_free()
