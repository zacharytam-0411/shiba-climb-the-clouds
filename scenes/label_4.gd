extends Label

@onready var label_4: Label = $"."

func _ready():
	label_4.text = "Gems: 0/2"

func _process(delta: float) -> void:
	var sapphire_status = "Sapphire: 1/1" if Global.sapphire_collected else "Sapphire: 0/1"
	var diamond_status =  "Diamond: 1/1" if Global.diamond_collected else "Diamond: 0/1"

	label_4.text = sapphire_status + "\n" + diamond_status
