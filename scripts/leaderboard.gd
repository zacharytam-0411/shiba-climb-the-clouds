extends Control

@onready var leaderboard_label: RichTextLabel = $CanvasLayer/LeaderboardLabel

# Example existing scores (manual input)
var scores: Array = [
	{"player": "another zac", "time": 76.0},
	{"player": "zac", "time": 217.5}
]

# Store the last run separately
var last_run: Dictionary = {}


func _ready() -> void:
	leaderboard_label.clear()
	add_pending_run()
	update_leaderboard()


func add_pending_run() -> void:
	if Global.pending_player == "" or Global.pending_time < 0.0:
		return

	# Insert the pending run into scores
	last_run = {
		"player": Global.pending_player,
		"time": Global.pending_time
	}
	scores.append(last_run)

	# Sort ascending (smaller = better)
	scores.sort_custom(func(a, b): return a["time"] < b["time"])

	# Reset so it doesn’t get added again
	Global.pending_player = ""
	Global.pending_time = -1.0


func update_leaderboard() -> void:
	leaderboard_label.clear()
	leaderboard_label.append_text(" Leaderboard \n")

	# Show top 10
	var top_count = min(10, scores.size())
	for i in range(top_count):
		var entry: Dictionary = scores[i]

		var line = "%d. %s - %.1fs" % [
			i + 1,
			entry["player"],
			entry["time"]
		]

		# Highlight the most recent run
		if entry == last_run:
			leaderboard_label.push_color(Color.GOLD)
			leaderboard_label.append_text(line + "\n")
			leaderboard_label.pop()
		else:
			leaderboard_label.append_text(line + "\n")

	# If the last run exists and is outside top 10, add extra row
	if last_run != {} and not scores.slice(0, top_count).has(last_run):
		leaderboard_label.append_text("------------------\n")
		leaderboard_label.push_color(Color.GOLD)
		leaderboard_label.append_text("Your time: %.1fs\n" % last_run["time"])
		leaderboard_label.pop()


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_screen.tscn") # Replace with function body.
