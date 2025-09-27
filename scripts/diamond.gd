extends Area2D
signal diamond_collected

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		Global.diamond_collected = true
		emit_signal("diamond_collected")
		queue_free()
	var msg_node = get_tree().root.get_node("main_game/CanvasLayer/BottomMessage")
	if msg_node:
		msg_node.show_message("Diamond Collected!")
