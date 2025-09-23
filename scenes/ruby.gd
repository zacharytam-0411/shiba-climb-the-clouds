extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		var msg_node = get_tree().get_first_node_in_group("message_ui")
		if msg_node and Global.ruby_collected == false:
			msg_node.show_message("Ruby Collected!")
		Global.ruby_collected = true
		queue_free()
