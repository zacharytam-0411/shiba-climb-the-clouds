# player.gd
extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0
const WALL_JUMP_PUSH = 200.0
const COYOTE_TIME := 0.1
const GRAVITY = 980.0

var coyote_timer: float = 0.0
var jumps_left: int = 1

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	_load_dino_animations(Global.selected_dino_color)
	randomize()

func _process(delta: float) -> void:
	Global.y_level = roundf((-position.y + 5) / 16)
	if Global.y_level > Global.max_height:
		Global.max_height = Global.y_level

func _physics_process(delta: float) -> void:
	if Global.dialogue_active:
		velocity = Vector2.ZERO
		animated_sprite.play("idle")
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y += GRAVITY * delta
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

	# Horizontal movement
	var direction := Input.get_axis("move_left", "move_right")

	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("move")
	else:
		animated_sprite.play("jump")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Random P action
	if Input.is_action_just_pressed("action_p"):
		_random_p_action()

	move_and_slide()

func _play_jump_sound() -> void:
	if jump_sound and jump_sound.stream:
		if jump_sound.playing:
			jump_sound.stop()
		jump_sound.play()

func _random_p_action():
	# Allow only if grounded OR has jumps left (sapphire double jump)
	if is_on_floor() or jumps_left > 0:
		# 1. Random jump boost
		var boost := randf_range(-400.0, -800.0)
		velocity.y = boost
		jumps_left -= 1
		_play_jump_sound()

		# 2. Pick random dino from all dinos (normal + secret)
		var pool = Global.available_dinos + Global.secret_dinos
		if pool.size() > 0:
			var new_color = pool.pick_random()
			Global.selected_dino_color = new_color
			_load_dino_animations(new_color)

		print("P pressed! Dino changed to:", Global.selected_dino_color, " with jump boost:", boost)

func _load_dino_animations(dino: String) -> void:
	var base_path = "res://assets/sprites/dinos/male/%s/base/" % dino
	var animations = ["idle", "move", "jump", "hurt", "dead", "dash", "kick", "bite", "avoid", "scan"]

	var frames = SpriteFrames.new()

	for anim in animations:
		var file_path = base_path + "%s.png" % anim
		if not ResourceLoader.exists(file_path):
			continue
		var tex = load(file_path)
		var frame_size = tex.get_height()
		var frame_count = tex.get_width() / frame_size
		frames.add_animation(anim)
		for i in range(int(frame_count)):
			var region = Rect2(i * frame_size, 0, frame_size, frame_size)
			var atlas = AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = region
			frames.add_frame(anim, atlas)

	animated_sprite.frames = frames
	animated_sprite.play("idle")

	# Adjust sprite offset for special dinos
	if dino == "krussy":
		animated_sprite.offset = Vector2(0, -3)  # move up by 6 pixels
	else:
		animated_sprite.offset = Vector2.ZERO

	animated_sprite.frames = frames
	animated_sprite.play("idle")

	# Scale adjustment for oversized dinos
	if dino == "krussy":
		animated_sprite.scale = Vector2(0.75, 0.75) # shrink Krussy
	else:
		animated_sprite.scale = Vector2(1, 1)
