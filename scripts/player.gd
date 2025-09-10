extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0
const WALL_JUMP_PUSH = 200.0
const COYOTE_TIME := 0.1
var coyote_timer: float = 0.0
var jumps_left: int = 1

@onready var animated_sprite = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var bgm_player: AudioStreamPlayer = $BGMPlayer
@onready var bgm_label: Label = $Camera2D/CanvasLayer/BGMLabel
@onready var label_timer: Timer = $BGMTimer

var bgm_list: Array = [
	{"name": "Overflow", "stream": preload("res://assets/music/オーバーライド - 重音テトSV[吉田夜世] - 吉田夜世.mp3")},
	{"name": "Tetoris", "stream": preload("res://assets/music/テトリス _ 重音テトSV - 柊マグネタイト.mp3")},
	{"name": "From the start", "stream": preload("res://assets/music/From The Start Cover __ 重音テトSV「Kasane Teto」 - SylviSlime.mp3")},
	{"name": "Lover Girl", "stream": preload("res://assets/music/Lover Girl __ 重音テトSV「Kasane Teto」 - SylviSlime.mp3")}
]
var current_bgm_index: int = 0
var end_timer: SceneTreeTimer = null


func _ready() -> void:
	# connect label timer
	if not label_timer.timeout.is_connected(_on_BGMLabelTimer_timeout):
		label_timer.timeout.connect(_on_BGMLabelTimer_timeout)

	# start first track
	_play_bgm(current_bgm_index)


func _play_bgm(index: int) -> void:
	if not bgm_player:
		return

	# cancel any old end timer
	if end_timer:
		end_timer.timeout.disconnect(_on_bgm_finished)
		end_timer = null

	current_bgm_index = index % bgm_list.size()
	var track = bgm_list[current_bgm_index]

	# play track
	bgm_player.stream = track["stream"]
	bgm_player.play()

	# update label
	if bgm_label and label_timer:
		bgm_label.text = "🎵 Now Playing: %s" % track["name"]
		bgm_label.visible = true
		label_timer.start()

	# create one-shot timer based on track length
	var song_length = track["stream"].get_length()
	if song_length > 0:
		end_timer = get_tree().create_timer(song_length + 0.1) # add small margin
		end_timer.timeout.connect(Callable(self, "_on_bgm_finished"), Object.CONNECT_ONE_SHOT)


func _on_bgm_finished() -> void:
	current_bgm_index = (current_bgm_index + 1) % bgm_list.size()
	_play_bgm(current_bgm_index)


func _on_BGMLabelTimer_timeout() -> void:
	if bgm_label:
		bgm_label.visible = false
func _process(delta: float) -> void:
	Global.y_level = roundf((-position.y+5)/16)
	if Global.y_level > Global.max_height:
		Global.max_height = Global.y_level

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		if Global.sapphire_collected:
			jumps_left = 2
		else:
			jumps_left = 1
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta
	
	if Input.is_action_just_pressed("move_up"):
		if is_on_floor() or coyote_timer > 0.0:
			velocity.y = JUMP_VELOCITY
			jumps_left -= 1
			coyote_timer = 0.0 
			_play_jump_sound()

		elif jumps_left > 0 and Global.sapphire_collected:
			velocity.y = JUMP_VELOCITY
			jumps_left -= 1
			_play_jump_sound()

		elif Global.ruby_collected and is_on_wall():
			var wall_normal := get_wall_normal().x
			velocity.y = JUMP_VELOCITY
			velocity.x = WALL_JUMP_PUSH * sign(wall_normal)
			if Global.sapphire_collected:
				jumps_left = 1
			else:
				jumps_left = 0
			_play_jump_sound()

	var direction := Input.get_axis("move_left", "move_right")

	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func _play_jump_sound() -> void:
	if jump_sound.playing:
		jump_sound.stop()
	jump_sound.play()
