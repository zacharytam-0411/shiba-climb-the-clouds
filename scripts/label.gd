extends Label
@onready var label: Label = $"."
@onready var player: CharacterBody2D

func _ready():
	label.text = "Y level: 0m"
	

func _process(delta: float) -> void:
	text = "Y level: " + str(Global.y_level) + "m" + "\nAll Tasks Completed: " + str(Global.winnable)
