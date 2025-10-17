extends Node2D

func _ready():
	var player = $Player
	player.player_id = "P2"
	$Player.initialize_player()
