# label3.gd
extends Label


#When player wins set this to false :))
var running = true

func _process(delta: float) -> void:
	if running:
		#much easier way to get time :))
		Global.timer += delta
		text = "Time: " + str(roundi(Global.timer*10)/10.0)
