extends CharacterBody2D

const BASE_SPEED = 150.0
const BASE_JUMP_VELOCITY = -300.0
const WALL_JUMP_PUSH = 200.0
const COYOTE_TIME := 0.1
const BASE_GRAVITY := 980.0

var SPEED = BASE_SPEED
var JUMP_VELOCITY = BASE_JUMP_VELOCITY

var coyote_timer: float = 0.0
var jumps_left: int = 1
var respawn_position: Vector2 = Vector2.ZERO
var is_respawning: bool = false
var player_id: String = "P1"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	var raw_selection: String = Global.selected_players.get(player_id, "KuroButton")
	if raw_selection == "" or raw_selection == null:
		raw_selection = "KuroButton"

	var selected_dino: String = raw_selection.replace("Button", "").to_lower()
	_load_dino_animations(selected_dino)

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

	var current_gravity := BASE_GRAVITY
	velocity.y += current_gravity * delta

	if is_on_floor():
		if Global.sapphire_collected or (Global.gamemode == "only_up" and Global.upgrades.get("DoubleJump", false)):
			jumps_left = 2
		else:
			jumps_left = 1
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
			jumps_left = 2 if Global.sapphire_collected or (Global.gamemode == "only_up" and Global.upgrades.get("DoubleJump", false)) else 1
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

	velocity.x = direction * SPEED if direction != 0 else move_toward(velocity.x, 0, SPEED)

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
			new_position = Vector2(global_position.x, global_position.y - 300)
	else:
		new_position = respawn_position

	global_position = new_position
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

	var msg_node_path = "DefaultMode/CanvasLayer/BottomMessage" if Global.gamemode == "default" else "OnlyUpMode/CanvasLayer/BottomMessage"
	var msg_node = get_tree().root.get_node_or_null(msg_node_path)

	match dino:
		"krussy":
			animated_sprite.offset = Vector2(0, -3)
			animated_sprite.scale = Vector2(0.75, 0.75)
		"shiba", "shibaina":
			animated_sprite.offset = Vector2(0, -2)
		"knight":
			pass
		_:
			animated_sprite.offset = Vector2.ZERO
			animated_sprite.scale = Vector2(1, 1)

func _apply_powerups() -> void:
	SPEED = BASE_SPEED
	JUMP_VELOCITY = BASE_JUMP_VELOCITY
	if Global.emerald_collected:
		SPEED *= 1.15
		JUMP_VELOCITY *= 1.1
	if Global.gamemode == "only_up":
		SPEED *= 1.5
		JUMP_VELOCITY *= 1.5
		var boost_level: int = Global.upgrades.get("JumpBoost", 0)
		if boost_level > 0:
			JUMP_VELOCITY *= 1 + (0.3 * boost_level)

func lose_life() -> void:
	if Global.lives > 0:
		Global.lives -= 1
		if Global.lives <= 0:
			Global._game_over()

func _process(delta: float) -> void:
	Global.y_level = -((global_position.y) / 16)
	if Global.y_level > Global.max_height:
		Global.max_height = Global.y_level
