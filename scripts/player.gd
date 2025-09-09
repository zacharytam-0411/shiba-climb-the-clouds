extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0
const WALL_JUMP_PUSH = 200.0

@onready var animated_sprite = $AnimatedSprite2D

var jumps_left: int = 1  # start with single jump only

func _process(delta: float) -> void:
	Global.y_level = roundf((-position.y+5)/16)
	if Global.y_level > Global.max_height:
		Global.max_height = Global.y_level

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		# Reset jumps depending on sapphire
		if Global.sapphire_collected:
			jumps_left = 2  # single jump + one extra
		else:
			jumps_left = 1  # only single jump

	# Handle jump input
	if Input.is_action_just_pressed("move_up"):
		if is_on_floor():
			# Normal jump
			velocity.y = JUMP_VELOCITY
			jumps_left -= 1
		elif jumps_left > 0:
			# Double jump (only if sapphire collected)
			if Global.sapphire_collected:
				velocity.y = JUMP_VELOCITY
				jumps_left -= 1
		elif Global.ruby_collected and is_on_wall():
			var direction := Input.get_axis("move_left", "move_right")
			var wall_normal := get_wall_normal().x
			# Require pressing toward the wall
			if (direction < 0 and wall_normal > 0) or (direction > 0 and wall_normal < 0):
				velocity.y = JUMP_VELOCITY
				velocity.x = WALL_JUMP_PUSH * sign(wall_normal)
				# Reset jumps depending on sapphire
				if Global.sapphire_collected:
					jumps_left = 1  # allow double jump after wall jump
				else:
					jumps_left = 0  # only wall jump, no double jump

	# Handle horizontal movement
	var direction := Input.get_axis("move_left", "move_right")

	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# Animation states
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	# Apply horizontal movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
