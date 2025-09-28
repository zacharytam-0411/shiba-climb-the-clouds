extends Node2D
@onready var y_label: Label = $CanvasLayer/YLevelLabel

func _process(_delta: float) -> void:
	y_label.text = "Y Level: %dm" % Global.y_level
