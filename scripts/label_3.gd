# label3.gd
extends Label

var timer = 0
#When player wins set this to false :))
var running = true

func _process(delta: float) -> void:
	if running:
		#much easier way to get time :))
		timer += delta
		text = "Time: " + str(roundi(timer*10)/10.0)
