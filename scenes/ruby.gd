extends Area2D
signal ruby_collected

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		Global.ruby_collected = true
		emit_signal("ruby_collected")
		queue_free()
		var msg_node = get_tree().get_first_node_in_group("message_ui")
		if msg_node and Global.ruby_collected == false:
			msg_node.show_message("Ruby Collected!")
