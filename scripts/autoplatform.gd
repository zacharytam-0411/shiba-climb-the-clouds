extends StaticBody2D

func _ready() -> void:
	add_to_group("platform")

func _on_TouchArea_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		var spawner := get_tree().current_scene.get_node_or_null("PlatformSpawner")
		if spawner:
			var id: int = int(body.get("player_id"))
			spawner.call("set_last_platform", id, global_position)
