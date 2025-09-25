extends Label

@onready var label_4: Label = $"."

func _process(delta: float) -> void:
	if Global.in_tutorial:
		hide()
	else:
		show()
	var sapphire_status = "Sapphire: 1/1" if Global.sapphire_collected else "Sapphire: 0/1"
	var diamond_status =  "Diamond: 1/1" if Global.diamond_collected else "Diamond: 0/1"
	var ruby_status = "Ruby: 1/1" if Global.ruby_collected else "Ruby: 0/1"
	var emerald_status = "Emerald: 1/1" if Global.emerald_collected else "Emerald: 0/1"

	label_4.text = "Task List:" + "\n" + sapphire_status + "\n" + diamond_status + "\n" + ruby_status + "\n" + emerald_status + "\nCoins: " + str(Global.coin) + "/32" + "\n" + "Lives: %d" % Global.lives + "\n" + "Y level: " + str(Global.y_level) + "m"
