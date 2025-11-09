extends Label
@onready var label: Label = $"."

func _process(delta: float) -> void:
	label.text = tr("lose_data") + "\n" + tr("lose_time_spent") + str(roundi(Global.timer*10)/10.0) + tr("lose_s") + "\n" + tr("lose_har") + str(Global.max_height) + "m" 
