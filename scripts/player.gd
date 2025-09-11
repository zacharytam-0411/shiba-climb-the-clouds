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

func _process(delta: float) -> void:
	Global.y_level = roundf((-position.y + 5) / 16)
	if Global.y_level > Global.max_height:
		Global.max_height = Global.y_level

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		if Engine.has_singleton("Global") and Global.sapphire_collected:
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

		elif Engine.has_singleton("Global") and jumps_left > 0 and Global.sapphire_collected:
			velocity.y = JUMP_VELOCITY
			jumps_left -= 1
			_play_jump_sound()

		elif Engine.has_singleton("Global") and Global.ruby_collected and is_on_wall():
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
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _play_jump_sound() -> void:
	if jump_sound and jump_sound.stream:
		if jump_sound.playing:
			jump_sound.stop()
		jump_sound.play()
