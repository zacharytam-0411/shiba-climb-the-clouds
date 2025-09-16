extends AudioStreamPlayer

@onready var bgm_label: Label = $"../Camera2D/CanvasLayer/BGMLabel"
@onready var label_timer: Timer = $"../BGMTimer"

var bgm_list: Array = [
	{"name": "Ochame Kinou", "stream": preload("res://assets/music/Ochame Kinou.mp3")},
	{"name": "Override", "stream": preload("res://assets/music/Overflow.mp3")},
	{"name": "Tetoris", "stream": preload("res://assets/music/Tetoris.mp3")},
	{"name": "From the start", "stream": preload("res://assets/music/From The Start.mp3")},
	{"name": "Lover Girl", "stream": preload("res://assets/music/Lover Girl.mp3")}
]

# Special track for Tutorial
var tutorial_bgm := {"name": "Zelda", "stream": preload("res://assets/music/Zelda.mp3")}

var current_bgm_index: int = 0
var end_timer: SceneTreeTimer = null
var bgm_started: bool = false

func _ready() -> void:
	# Connect timer if not already
	if not label_timer.timeout.is_connected(Callable(self, "_on_BGMLabelTimer_timeout")):
		label_timer.timeout.connect(Callable(self, "_on_BGMLabelTimer_timeout"))

	# Always hide label at start
	if bgm_label:
		bgm_label.visible = false

	# Tutorial → force Zelda
	if get_tree().current_scene and get_tree().current_scene.name == "Tutorial":
		bgm_started = true
		_play_tutorial_bgm()
		return

	# Normal scenes → start music rotation
	bgm_started = true
	_play_bgm(current_bgm_index)


func _unhandled_input(event: InputEvent) -> void:
	# For Web builds: start BGM on first input
	if OS.get_name() == "Web" and not bgm_started:
		if get_tree().current_scene and get_tree().current_scene.name == "Tutorial":
			bgm_started = true
			_play_tutorial_bgm()
			return

		if (event is InputEventKey and event.pressed) \
		or (event is InputEventMouseButton and event.pressed) \
		or (event is InputEventScreenTouch and event.pressed):
			bgm_started = true
			_play_bgm(current_bgm_index)


func _play_bgm(index: int) -> void:
	# Cancel old timer safely
	if end_timer:
		if end_timer.timeout.is_connected(Callable(self, "_on_bgm_finished")):
			end_timer.timeout.disconnect(Callable(self, "_on_bgm_finished"))
		end_timer = null

	current_bgm_index = index % bgm_list.size()
	var track = bgm_list[current_bgm_index]

	# Play track
	stream = track["stream"]
	play()

	# Update label
	if bgm_label and label_timer:
		bgm_label.text = "🎵 Now Playing: %s" % track["name"]
		bgm_label.visible = true
		label_timer.start()

	# One-shot timer for track length
	var song_length = track["stream"].get_length()
	if song_length > 0.0:
		end_timer = get_tree().create_timer(song_length + 0.5)
		if not end_timer.timeout.is_connected(Callable(self, "_on_bgm_finished")):
			end_timer.timeout.connect(Callable(self, "_on_bgm_finished"), Object.CONNECT_ONE_SHOT)


func _play_tutorial_bgm() -> void:
	# Cancel old timers
	if end_timer:
		if end_timer.timeout.is_connected(Callable(self, "_on_bgm_finished")):
			end_timer.timeout.disconnect(Callable(self, "_on_bgm_finished"))
		end_timer = null

	# Play Zelda
	stream = tutorial_bgm["stream"]
	play()

	# Update label
	if bgm_label and label_timer:
		bgm_label.text = "🎵 Now Playing: %s" % tutorial_bgm["name"]
		bgm_label.visible = true
		label_timer.start()
	# No looping rotation – just Zelda forever


func _on_bgm_finished() -> void:
	current_bgm_index = (current_bgm_index + 1) % bgm_list.size()
	_play_bgm(current_bgm_index)


func _on_BGMLabelTimer_timeout() -> void:
	if bgm_label:
		bgm_label.visible = false
