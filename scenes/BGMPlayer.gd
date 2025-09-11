extends AudioStreamPlayer

@onready var bgm_label: Label = $"../Camera2D/CanvasLayer/BGMLabel"
@onready var label_timer: Timer = $"../BGMTimer"

var bgm_list: Array = [
	{"name": "Overflow", "stream": preload("res://assets/music/オーバーライド - 重音テトSV[吉田夜世] - 吉田夜世.mp3")},
	{"name": "Tetoris", "stream": preload("res://assets/music/テトリス _ 重音テトSV - 柊マグネタイト.mp3")},
	{"name": "From the start", "stream": preload("res://assets/music/From The Start Cover __ 重音テトSV「Kasane Teto」 - SylviSlime.mp3")},
	{"name": "Lover Girl", "stream": preload("res://assets/music/Lover Girl __ 重音テトSV「Kasane Teto」 - SylviSlime.mp3")}
]
var current_bgm_index: int = 0
var end_timer: SceneTreeTimer = null
var bgm_started: bool = false

func _ready() -> void:
	# Connect label timer
	if not label_timer.timeout.is_connected(Callable(self, "_on_BGMLabelTimer_timeout")):
		label_timer.timeout.connect(Callable(self, "_on_BGMLabelTimer_timeout"))
	
	# Hide label at start
	if bgm_label:
		bgm_label.visible = false
	
	# Start immediately only on non-Web platforms
	if OS.get_name() != "Web":
		bgm_started = true
		_play_bgm(current_bgm_index)


func _unhandled_input(event: InputEvent) -> void:
	# For Web builds: start BGM on first key press, mouse click, or touch
	if OS.get_name() == "Web" and not bgm_started:
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
		end_timer = get_tree().create_timer(song_length + 0.5)  # extra margin
		if not end_timer.timeout.is_connected(Callable(self, "_on_bgm_finished")):
			end_timer.timeout.connect(Callable(self, "_on_bgm_finished"), Object.CONNECT_ONE_SHOT)


func _on_bgm_finished() -> void:
	current_bgm_index = (current_bgm_index + 1) % bgm_list.size()
	_play_bgm(current_bgm_index)


func _on_BGMLabelTimer_timeout() -> void:
	if bgm_label:
		bgm_label.visible = false
