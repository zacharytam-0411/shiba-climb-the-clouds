# label3.gd
extends Label

var running = true

func _process(delta: float) -> void:
	if Global.in_tutorial:
		hide()
	else:
		show()
	if running:
		#much easier way to get time :))
		Global.timer += delta
		text = "Time: " + str(roundi(Global.timer*10)/10.0)
