extends Label
@onready var label: Label = $"."

func _process(delta: float) -> void:
	label.text = "Your Data: " + "\nDeaths: " + str(Global.deaths) + "\nTime: " + str(roundi(Global.timer*10)/10.0) + "s" + "\nHighest Altitude Reached: " + str(Global.max_height) + "m" 
