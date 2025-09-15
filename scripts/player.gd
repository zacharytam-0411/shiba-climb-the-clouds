extends CharacterBody2D

# --- Movement constants ---
const SPEED = 150.0
const JUMP_VELOCITY = -300.0
const WALL_JUMP_PUSH = 200.0
const COYOTE_TIME := 0.1
const GRAVITY = 980.0

# --- Variables ---
var coyote_timer: float = 0.0
var jumps_left: int = 1

# --- Nodes ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

# --- Ready ---
func _ready() -> void:
	# Load animations based on chosen dino color
	_load_dino_animations(Global.selected_dino_color)


# --- Process ---
func _process(delta: float) -> void:
	Global.y_level = roundf((-position.y + 5) / 16)
	if Global.y_level > Global.max_height:
		Global.max_height = Global.y_level


# --- Physics Process ---
func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		if Global.sapphire_collected:
			jumps_left = 2
		else:
			jumps_left = 1

	# Coyote time update
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta

	# Handle jumping
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

	# Handle horizontal movement
	var direction := Input.get_axis("move_left", "move_right")

	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("move") # or "run" if your PNG uses that name
	else:
		animated_sprite.play("jump")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


# --- Sounds ---
func _play_jump_sound() -> void:
	if jump_sound and jump_sound.stream:
		if jump_sound.playing:
			jump_sound.stop()
		jump_sound.play()


# --- Dynamic animation loader ---
func _load_dino_animations(dino: String) -> void:
	var base_path = "res://assets/sprites/dinos/male/%s/base/" % dino
	var animations = ["idle", "move", "jump", "hurt", "dead", "dash", "kick", "bite", "avoid", "scan"]

	var frames = SpriteFrames.new()

	for anim in animations:
		var file_path = base_path + "%s.png" % anim
		if not ResourceLoader.exists(file_path):
			continue

		var tex = load(file_path)
		var frame_size = tex.get_height() # assumes square frames
		var frame_count = tex.get_width() / frame_size

		frames.add_animation(anim)

		for i in range(int(frame_count)):
			var region = Rect2(i * frame_size, 0, frame_size, frame_size)
			var atlas = AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = region
			frames.add_frame(anim, atlas)

	# Assign the dynamically built SpriteFrames
	animated_sprite.frames = frames
	animated_sprite.play("idle")
