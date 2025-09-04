# Label.gd
extends Label

# This line needs to be changed:
@onready var player_node = get_node("../../../") # Go up three times

func _ready():
	if player_node:
		player_node.connect("update_position", _on_update_position) 
	else:
		print("Error: Player node not found for Y_Position_Label connection!")

func _on_update_position(pos_y: float):
	var real_y = (floor(-pos_y) / 16) - 0.6875
	text = "Height: " + str(int(floor(real_y))) + "m"
