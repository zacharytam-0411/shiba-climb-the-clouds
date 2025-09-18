extends AudioStreamPlayer

@onready var bgm_label: Label = $"../Camera2D/CanvasLayer/BGMLabel"
@onready var label_timer: Timer = $"../BGMTimer"

var bgm_list: Array = [
	{"name": "Ochame Kinou - LamazeP [feat. Kasane Teto]", "stream": preload("res://assets/music/Ochame Kinou.mp3")},
	{"name": "Override - Yoshida Yasei [feat. Kasane Teto]", "stream": preload("res://assets/music/Overflow.mp3")},
	{"name": "Tetoris - Hiiragi Magnetite [feat. Kasane Teto]", "stream": preload("res://assets/music/Tetoris.mp3")},
	{"name": "From The Start - Laufey [feat. Kasane Teto]", "stream": preload("res://assets/music/From The Start.mp3")},
	{"name": "Lover Girl - Laufey [feat. Kasane Teto]", "stream": preload("res://assets/music/Lover Girl.mp3")},
	{"name": "Rainbow Road Theme [Mario Kart World]", "stream": preload("res://assets/music/Rainbow Road.mp3")}
]

# Special track for Tutorial
var tutorial_bgm := {"name": "Theme from the Legend of Zelda - Koji Kondo", "stream": preload("res://assets/music/Zelda.mp3")}

var current_bgm_index: int = 0
var end_timer: SceneTreeTimer = null
var bgm_started: bool = false

func _ready() -> void:
	if not label_timer.timeout.is_connected(Callable(self, "_on_BGMLabelTimer_timeout")):
		label_timer.timeout.connect(Callable(self, "_on_BGMLabelTimer_timeout"))

	if bgm_label:
		bgm_label.visible = false

	if get_tree().current_scene and get_tree().current_scene.name == "Tutorial":
		bgm_started = true
		_play_tutorial_bgm()
		return

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

	# Skip forward (P key)
	if event.is_action_pressed("skip_bgm_next"):
		_skip_next_bgm()

	# Skip backward (O key)
	if event.is_action_pressed("skip_bgm_prev"):
		_skip_prev_bgm()


func _play_bgm(index: int) -> void:
	_cancel_end_timer()

	current_bgm_index = index % bgm_list.size()
	var track = bgm_list[current_bgm_index]

	stream = track["stream"]
	play()

	if bgm_label and label_timer:
		bgm_label.text = "🎵 Now Playing: %s" % track["name"]
		bgm_label.visible = true
		label_timer.start()

	var song_length = track["stream"].get_length()
	if song_length > 0.0:
		end_timer = get_tree().create_timer(song_length + 0.5)
		if not end_timer.timeout.is_connected(Callable(self, "_on_bgm_finished")):
			end_timer.timeout.connect(Callable(self, "_on_bgm_finished"), Object.CONNECT_ONE_SHOT)


func _play_tutorial_bgm() -> void:
	_cancel_end_timer()

	stream = tutorial_bgm["stream"]
	play()

	if bgm_label and label_timer:
		bgm_label.text = "🎵 Now Playing: %s" % tutorial_bgm["name"]
		bgm_label.visible = true
		label_timer.start()
	# Zelda loops forever


func _on_bgm_finished() -> void:
	_skip_next_bgm()


func _skip_next_bgm() -> void:
	current_bgm_index = (current_bgm_index + 1) % bgm_list.size()
	_play_bgm(current_bgm_index)


func _skip_prev_bgm() -> void:
	current_bgm_index = (current_bgm_index - 1 + bgm_list.size()) % bgm_list.size()
	_play_bgm(current_bgm_index)


func _on_BGMLabelTimer_timeout() -> void:
	if bgm_label:
		bgm_label.visible = false


func _cancel_end_timer() -> void:
	if end_timer:
		if end_timer.timeout.is_connected(Callable(self, "_on_bgm_finished")):
			end_timer.timeout.disconnect(Callable(self, "_on_bgm_finished"))
		end_timer = null
