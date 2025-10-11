extends Control

@onready var leaderboard_label: RichTextLabel = $CanvasLayer/LeaderboardLabel

# Placeholder entries
var scores := [
	{"player": "Sena", "time": 88.9},
	{"player": "Mono", "time": 99.1},
	{"player": "Olaf", "time": 123.4},
	{"player": "Mort", "time": 142.3},
	{"player": "Zac", "time": 217.5}
]

func _ready() -> void:
	update_leaderboard()

func update_leaderboard() -> void:
	leaderboard_label.clear()
	leaderboard_label.append_text("🏁 Leaderboard\n\n")

	for i in range(scores.size()):
		var entry: Dictionary = scores[i]
		var line := "%d. %s - %.1fs\n" % [i + 1, entry["player"], entry["time"]]
		leaderboard_label.append_text(line)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_screen.tscn") # Replace with function body.
