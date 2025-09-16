extends Label
@onready var label_2: Label = $"."

func _process(delta: float) -> void:
	if Global.in_tutorial:
		hide()
	else:
		show()
	label_2.text = "Deaths: " + str(Global.deaths) + "\nCoins: " + str(Global.coin) + "/25"
