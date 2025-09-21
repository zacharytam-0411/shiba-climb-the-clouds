extends Control

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var leaderboard_label: Label = $CanvasLayer/LeaderboardLabel

const ENDPOINT := "https://script.google.com/macros/s/AKfycbwcOTXY6O7N0YFuRJL6EX8nTek3MSZ81sHFbLlufbUqxdzWftHtqAZDvTBkPNhzcuYfzg/exec"

var pending_player := ""
var pending_score := -1.0


func _ready() -> void:
	if Global.pending_player != "" and Global.pending_score >= 0.0:
		submit_score(Global.pending_player, Global.pending_score)
		Global.pending_player = ""
		Global.pending_score = -1.0
	else:
		fetch_leaderboard()
		leaderboard_label.text = "Fetching leaderboard..."



func submit_score(player_name: String, finish_time: float) -> void:
	pending_player = player_name
	pending_score = finish_time

	var body = {"player": player_name, "score": finish_time}
	var json_body = JSON.stringify(body)

	if http_request.get_http_client_status() == HTTPClient.STATUS_REQUESTING:
		return

	var err = http_request.request(
		ENDPOINT,
		["Content-Type: application/json"],
		HTTPClient.METHOD_POST,
		json_body
	)

	if err != OK:
		push_error("Failed to submit score: %s" % err)


func fetch_leaderboard() -> void:
	if http_request.get_http_client_status() == HTTPClient.STATUS_REQUESTING:
		return

	var err = http_request.request(
		ENDPOINT,
		[],
		HTTPClient.METHOD_GET
	)

	if err != OK:
		push_error("Failed to fetch leaderboard: %s" % err)


func _on_HTTPRequest_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code != 200:
		push_error("Leaderboard request failed: %s" % response_code)
		return

	var text = body.get_string_from_utf8()
	var json = JSON.parse_string(text)
	if json == null:
		push_error("Failed to parse JSON")
		return

	# If this was a POST, fetch updated leaderboard
	if pending_player != "" and pending_score >= 0.0:
		pending_player = ""
		pending_score = -1.0
		fetch_leaderboard()
		return

	# --- Sort by score ascending (best first) ---
	json.sort_custom(func(a, b): return float(a.score) < float(b.score))

	# --- Build leaderboard text ---
	var display_text = "🏆 Leaderboard 🏆\n"
	var count := 0

	for entry in json:
		if count >= 10: # limit to top 10
			break

		var timestamp_str := str(entry.timestamp)
		var formatted_time := timestamp_str

		# Manually parse Google Sheets format "M/d/yyyy H:mm:ss"
		var parts = timestamp_str.split(" ")
		if parts.size() == 2:
			var date_parts = parts[0].split("/")
			var time_parts = parts[1].split(":")
			if date_parts.size() == 3 and time_parts.size() >= 2:
				var month = int(date_parts[0])
				var day = int(date_parts[1])
				var year = int(date_parts[2])
				var hour = int(time_parts[0])
				var minute = int(time_parts[1])
				formatted_time = "%04d/%02d/%02d %02d:%02d" % [
					year, month, day, hour, minute
				]

		display_text += "%d. %s - %.1fs (%s)\n" % [
			count + 1,
			entry.player,
			entry.score,
			formatted_time
		]

		count += 1

	leaderboard_label.text = display_text
