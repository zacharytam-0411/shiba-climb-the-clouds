extends AudioStreamPlayer2D

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("move_up"):
		pitch_scale = randf_range(0.7, 1.3)
