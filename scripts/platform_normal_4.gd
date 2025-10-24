extends StaticBody2D

var game_started_time: float = 0.0
var player_times := {}  # Dictionary to store win times per player name

func _ready():
	game_started_time = Time.get_ticks_msec() / 1000.0  # seconds

func _on_area2d_body_entered(body):
	if not body.is_in_group("player"):
		return

	var player_name : String = body.name
	if player_name in player_times:
		return  # Already recorded this player's time

	if body.has_method("win_game"):
		var elapsed = Time.get_ticks_msec() / 1000.0 - game_started_time
		player_times[player_name] = elapsed
		print("You win! %s's time: %.2f seconds" % [player_name, elapsed])
		body.win_game()
