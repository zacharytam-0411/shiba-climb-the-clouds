extends Button

func _process(delta: float) -> void:
	if Global.tutorial_completed:
		show()
	else:
		hide()
