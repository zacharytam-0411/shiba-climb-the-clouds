# Player.gd
extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0

signal update_position(pos_y: float) # Signal defined here


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	# Emit the signal with the player's current y-position
	emit_signal("update_position", global_position.y) # Use global_position for world coordinates
