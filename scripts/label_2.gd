extends Label
@onready var label_2: Label = $"."

func _process(delta: float) -> void:
	label_2.text = "Deaths: " + str(Global.deaths) + "\nCoins: " + str(Global.coin) + "/25"
