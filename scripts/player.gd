extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0
const WALL_JUMP_PUSH = 200.0
const COYOTE_TIME := 0.1
var coyote_timer: float = 0.0


@onready var animated_sprite = $AnimatedSprite2D

var jumps_left: int = 1

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

		elif jumps_left > 0 and Global.sapphire_collected:
			velocity.y = JUMP_VELOCITY
			jumps_left -= 1

		elif Global.ruby_collected and is_on_wall():
			var wall_normal := get_wall_normal().x
			velocity.y = JUMP_VELOCITY
			velocity.x = WALL_JUMP_PUSH * sign(wall_normal)
			if Global.sapphire_collected:
				jumps_left = 1
			else:
				jumps_left = 0

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
