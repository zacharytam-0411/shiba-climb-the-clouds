extends Node2D

func _ready():
	var player = $Player
	player.set_player_id("P2")
	player.initialize_player()
