extends CharacterBody2D

const BASE_SPEED = 150.0
const BASE_JUMP_VELOCITY = -300.0
const WALL_JUMP_PUSH = 200.0
const COYOTE_TIME := 0.1
const GRAVITY = 980.0

var SPEED = BASE_SPEED
var JUMP_VELOCITY = BASE_JUMP_VELOCITY

var coyote_timer: float = 0.0
var jumps_left: int = 1
var respawn_position: Vector2 = Vector2.ZERO
var is_respawning: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	_load_dino_animations(Global.selected_dino_color)
	randomize()
	add_to_group("player")
	respawn_position = global_position
	_apply_powerups()

	var void_area := get_tree().current_scene.get_node_or_null("Void")
	if void_area and void_area.has_signal("player_died"):
		void_area.player_died.connect(_on_player_died)

func _physics_process(delta: float) -> void:
	if Global.dialogue_active or is_respawning:
		velocity = Vector2.ZERO
		animated_sprite.play("idle")
		move_and_slide()
		return

	_apply_powerups()

	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		if Global.sapphire_collected or (Global.gamemode == "only_up" and Global.upgrades.get("DoubleJump", false)):
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
		elif jumps_left > 0 and (Global.sapphire_collected or (Global.gamemode == "only_up" and Global.upgrades.get("DoubleJump", false))):
			velocity.y = JUMP_VELOCITY
			jumps_left -= 1
			_play_jump_sound()
		elif Global.ruby_collected and is_on_wall():
			var wall_normal := get_wall_normal().x
			velocity.y = JUMP_VELOCITY
			velocity.x = WALL_JUMP_PUSH * sign(wall_normal)
			jumps_left = 1 if Global.sapphire_collected or (Global.gamemode == "only_up" and Global.upgrades.get("DoubleJump", false)) else 0

			_play_jump_sound()

	var direction := Input.get_axis("move_left", "move_right")
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	if is_on_floor():
		animated_sprite.play("idle" if direction == 0 else "move")
	else:
		animated_sprite.play("jump")

	velocity.x = direction * SPEED if direction else move_toward(velocity.x, 0, SPEED)

	if Input.is_action_just_pressed("action_p"):
		_random_p_action()

	move_and_slide()

func _on_player_died(player: Node) -> void:
	if player != self:
		return

	is_respawning = true
	lose_life()

	var overlay := get_tree().current_scene.get_node("DeathOverlay")
	if overlay:
		overlay.start_reveal(respawn_position)

	await get_tree().create_timer(0.1).timeout

	respawn()

	if overlay:
		overlay.reveal_circle(respawn_position)

	is_respawning = false

func respawn() -> void:
	var new_position: Vector2

	if Global.gamemode == "only_up":
		var spawner := get_tree().current_scene.get_node_or_null("OnlyUpMode/PlatformSpawner")
		if spawner and "get_respawn_position" in spawner:
			new_position = spawner.get_respawn_position()
		else:
			new_position = Vector2(global_position.x, global_position.y - 300)  # fallback
	else:
		new_position = respawn_position  # set via set_checkpoint()

	global_position = new_position
	velocity = Vector2.ZERO
	animated_sprite.play("idle")


	global_position = new_position  # ← use this, not set_deferred
	velocity = Vector2.ZERO
	animated_sprite.play("idle") 
	move_and_slide()



func set_checkpoint(pos: Vector2) -> void:
	respawn_position = pos

func _play_jump_sound() -> void:
	if jump_sound and jump_sound.stream:
		if jump_sound.playing:
			jump_sound.stop()
		jump_sound.play()

func _random_p_action():
	if is_on_floor() or jumps_left > 0:
		var boost := randf_range(-500.0, -1000.0)
		velocity.y = boost
		jumps_left -= 1
		_play_jump_sound()
		print("P pressed! Dino jump boost:", boost)

	var pool = Global.available_dinos + Global.secret_dinos
	if pool.size() > 0:
		var new_color = pool.pick_random()
		Global.selected_dino_color = new_color
		_load_dino_animations(new_color)

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
	
	if Global.gamemode == "default":
		if dino == "krussy":
			animated_sprite.offset = Vector2(0, -3)
			animated_sprite.scale = Vector2(0.75, 0.75)
			var msg_node = get_tree().root.get_node("DefaultMode/CanvasLayer/BottomMessage")
			if msg_node:
				msg_node.show_message("Now Featuring : Krussy from a game made by Raqeeb")
		elif dino == "shiba":
			animated_sprite.offset = Vector2(0, -2)
			var msg_node = get_tree().root.get_node("DefaultMode/CanvasLayer/BottomMessage")
			if msg_node:
				msg_node.show_message("Now Featuring : Shiba from ShibaRunner - xvcf")
		elif dino == "shibaina":
			animated_sprite.offset = Vector2(0, -2)
			var msg_node = get_tree().root.get_node("DefaultMode/CanvasLayer/BottomMessage")
			if msg_node:
				msg_node.show_message("Now Featuring : Shibaina from ShibaRunner - xvcf")
		elif dino == "knight":
			var msg_node = get_tree().root.get_node("DefaultMode/CanvasLayer/BottomMessage")
			if msg_node:
				msg_node.show_message("Now Featuring : Knight from Brackey's Tutorial")
		else:
			animated_sprite.offset = Vector2.ZERO
			animated_sprite.scale = Vector2(1, 1)
	else:
		if dino == "krussy":
			animated_sprite.offset = Vector2(0, -3)
			animated_sprite.scale = Vector2(0.75, 0.75)
			var msg_node = get_tree().root.get_node("OnlyUpMode/CanvasLayer/BottomMessage")
			if msg_node:
				msg_node.show_message("Now Featuring : Krussy from a game made by Raqeeb")
		elif dino == "shiba":
			animated_sprite.offset = Vector2(0, -2)
			var msg_node = get_tree().root.get_node("OnlyUpMode/CanvasLayer/BottomMessage")
			if msg_node:
				msg_node.show_message("Now Featuring : Shiba from ShibaRunner - xvcf")
		elif dino == "shibaina":
			animated_sprite.offset = Vector2(0, -2)
			var msg_node = get_tree().root.get_node("OnlyUpMode/CanvasLayer/BottomMessage")
			if msg_node:
				msg_node.show_message("Now Featuring : Shibaina from ShibaRunner - xvcf")
		elif dino == "knight":
			var msg_node = get_tree().root.get_node("OnlyUpMode/CanvasLayer/BottomMessage")
			if msg_node:
				msg_node.show_message("Now Featuring : Knight from Brackey's Tutorial")
		else:
			animated_sprite.offset = Vector2.ZERO
			animated_sprite.scale = Vector2(1, 1)

func _apply_powerups() -> void:
	SPEED = BASE_SPEED
	JUMP_VELOCITY = BASE_JUMP_VELOCITY
	if Global.emerald_collected:
		SPEED *= 1.15
		JUMP_VELOCITY *= 1.1
	if Global.gamemode == "only_up":
		SPEED *= 1.33
		JUMP_VELOCITY *= 1.33
		var boost_level:int = Global.upgrades.get("JumpBoost", 0)
		if boost_level > 0:
			JUMP_VELOCITY *= 1.0 + (0.1 * boost_level)  # +10% per level


func lose_life() -> void:
	if Global.lives > 0:
		Global.lives -= 1
		if Global.lives > 0:
			print("Lives left:", Global.lives)
		else:
			Global._game_over()

func _process(delta: float) -> void:
	Global.y_level = -((global_position.y)/16)
	if Global.y_level > Global.max_height:
		Global.max_height = Global.y_level
