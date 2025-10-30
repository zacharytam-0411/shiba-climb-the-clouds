extends StaticBody2D

signal both_players_finished

var game_started_time: float = 0.0
var player_times := {}  # Dictionary to store win times per player name

func _ready():
	game_started_time = Time.get_ticks_msec() / 1000.0  # seconds

func _on_area2d_body_entered(body):
	if not body.is_in_group("player"):
		return

	var player_name: String = body.player_id
	if player_name in player_times:
		return  # Already recorded this player's time

	if body.has_method("win_game"):
		var elapsed = Time.get_ticks_msec() / 1000.0 - game_started_time
		player_times[player_name] = elapsed
		print("✅ %s reached the goal in %.2fs" % [player_name, elapsed])
		body.win_game(elapsed)

		if player_times.size() == 2:
			emit_signal("both_players_finished")
