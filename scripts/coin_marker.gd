extends Sprite2D

func _on_coin_collected() -> void:  # ✅ Debug print
	queue_free()
