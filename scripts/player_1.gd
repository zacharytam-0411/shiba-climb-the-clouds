extends Node2D

func _ready():
	var player = $Player
	player.player_id = "P1"
	$Player.initialize_player()
