extends AudioStreamPlayer

@onready var bgm_label: Label = get_tree().get_first_node_in_group("bgm_ui")
@onready var label_timer: Timer = $"../BGMTimer"

var bgm_list: Array = [
	{"name": "PPPP - TAK [feat. Kasane Teto, Hatsune Miku]", "stream": preload("res://assets/music/PPPP.mp3")},
	{"name": "Lemon Melon Cookie - TAK [feat. Hatsune Miku]", "stream": preload("res://assets/music/Lemon Melon Cookie.mp3")},
	{"name": "Konton Boogie - jon-YAKITORY [feat. WxS]", "stream": preload("res://assets/music/Konton Boogie.mp3")},
	{"name": "Ochame Kinou - LamazeP [feat. Kasane Teto]", "stream": preload("res://assets/music/Ochame Kinou.mp3")},
	{"name": "Override - Yoshida Yasei [feat. Kasane Teto]", "stream": preload("res://assets/music/Overflow.mp3")},
	{"name": "Tetoris - Hiiragi Magnetite [feat. Kasane Teto]", "stream": preload("res://assets/music/Tetoris.mp3")},
	{"name": "From The Start - Laufey [feat. Kasane Teto]", "stream": preload("res://assets/music/From The Start.mp3")},
	{"name": "Lover Girl - Laufey [feat. Kasane Teto]", "stream": preload("res://assets/music/Lover Girl.mp3")},
	{"name": "Rainbow Road Theme [Mario Kart World]", "stream": preload("res://assets/music/Rainbow Road.mp3")},
	{"name": "Kirapipi🌟Kirapika - nyanyannya", "stream": preload("res://assets/music/Kirapipi Kirapika.mp3")},
	{"name": "Shimmering Shapes - doctorn0gloff", "stream": preload("res://assets/music/Shimmering Shapes.mp3")}
]

# Special track for Tutorial (loops forever)
var tutorial_bgm := {"name": "Theme from the Legend of Zelda - Koji Kondo", "stream": preload("res://assets/music/Zelda.mp3")}

var current_bgm_index: int = 0
var bgm_started: bool = false

# timers for fade scheduling
var fade_timer: SceneTreeTimer = null
const FADE_DURATION := 0.5  # seconds to fade out/in

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
		_crossfade_to((current_bgm_index + 1) % bgm_list.size())

	# Skip backward (O key)
	if event.is_action_pressed("skip_bgm_prev"):
		_crossfade_to((current_bgm_index - 1 + bgm_list.size()) % bgm_list.size())


func _play_bgm(index: int) -> void:
	_cancel_fade_timer()

	current_bgm_index = index % bgm_list.size()
	var track = bgm_list[current_bgm_index]

	# make sure looping is disabled
	if track["stream"].has_method("set_loop"):
		track["stream"].set_loop(false)
	elif "loop" in track["stream"]:
		track["stream"].loop = false

	stream = track["stream"]
	volume_db = 0
	play()

	if bgm_label and label_timer:
		bgm_label.text = "🎵 Now Playing: %s" % track["name"]
		bgm_label.visible = true
		label_timer.start()

	# schedule fade before end of song
	var song_length = track["stream"].get_length()
	if song_length > FADE_DURATION:
		fade_timer = get_tree().create_timer(song_length - FADE_DURATION)
		fade_timer.timeout.connect(Callable(self, "_fade_out_and_skip"), CONNECT_ONE_SHOT)


func _play_tutorial_bgm() -> void:
	_cancel_fade_timer()

	# tutorial BGM loops forever
	if tutorial_bgm["stream"].has_method("set_loop"):
		tutorial_bgm["stream"].set_loop(true)
	elif "loop" in tutorial_bgm["stream"]:
		tutorial_bgm["stream"].loop = true

	stream = tutorial_bgm["stream"]
	volume_db = 0
	play()

	if bgm_label and label_timer:
		bgm_label.text = "🎵 Now Playing: %s" % tutorial_bgm["name"]
		bgm_label.visible = true
		label_timer.start()


# --- Fading logic ---

func _fade_out_and_skip() -> void:
	var tween := create_tween()
	tween.tween_property(self, "volume_db", -40, FADE_DURATION)
	tween.finished.connect(Callable(self, "_on_fade_out_done"), CONNECT_ONE_SHOT)


func _on_fade_out_done() -> void:
	_skip_next_bgm()
	volume_db = -20
	var tween := create_tween()
	tween.tween_property(self, "volume_db", 0, FADE_DURATION)


# crossfade helper for manual skipping
func _crossfade_to(next_index: int) -> void:
	_cancel_fade_timer()

	var tween := create_tween()
	tween.tween_property(self, "volume_db", -20, FADE_DURATION)
	tween.finished.connect(
		func ():
			_play_bgm(next_index)
			volume_db = -20
			var fade_in_tween := create_tween()
			fade_in_tween.tween_property(self, "volume_db", 0, FADE_DURATION),
		CONNECT_ONE_SHOT
	)


# --- Next / Previous ---

func _skip_next_bgm() -> void:
	_play_bgm((current_bgm_index + 1) % bgm_list.size())


func _skip_prev_bgm() -> void:
	_play_bgm((current_bgm_index - 1 + bgm_list.size()) % bgm_list.size())


# --- Label handling ---

func _on_BGMLabelTimer_timeout() -> void:
	if bgm_label:
		bgm_label.visible = false


# --- Utility ---

func _cancel_fade_timer() -> void:
	if fade_timer:
		if fade_timer.timeout.is_connected(Callable(self, "_fade_out_and_skip")):
			fade_timer.timeout.disconnect(Callable(self, "_fade_out_and_skip"))
		fade_timer = null
