extends CharacterBody2D

const BASE_SPEED: float = 200.0
const BASE_JUMP_VELOCITY: float = -400.0
const WALL_JUMP_PUSH: float = 200.0
const COYOTE_TIME: float = 0.1
const BASE_GRAVITY: float = 980.0
const RESPAWN_THRESHOLD: float = 100.0

# Runtime variables
var SPEED: float = BASE_SPEED
var JUMP_VELOCITY: float = BASE_JUMP_VELOCITY
var coyote_timer: float = 0.0
var jumps_left: int = 1
var respawn_position: Vector2 = Vector2.ZERO
var last_platform_position: Vector2 = Vector2.ZERO
var is_respawning: bool = false
var respawn_cooldown: float = 0.0

# Platform climb tracking
var platforms_climbed: int = 0
@export var total_platforms: int = 0
var climb_label: Label = null

@export var player_id: String = "P1"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	randomize()
	add_to_group("player")
	respawn_position = global_position
	last_platform_position = global_position
	_apply_powerups()
	_update_climb_display()

func set_climb_label(label: Label) -> void:
	climb_label = label
	_update_climb_display()

func set_total_platforms(count: int) -> void:
	total_platforms = count
	_update_climb_display()

func _physics_process(delta: float) -> void:
	if Global.dialogue_active or is_respawning:
		velocity = Vector2.ZERO
		animated_sprite.play("idle")
		move_and_slide()
		return

	if respawn_cooldown > 0.0:
		respawn_cooldown -= delta

	_apply_powerups()

	var gravity_multiplier: float = 1.5 if Global.gamemode == "2p" else 1.0
	velocity.y += BASE_GRAVITY * gravity_multiplier * delta

	if is_on_floor():
		jumps_left = 2 if Global.sapphire_collected or (Global.gamemode == "only_up" and Global.upgrades.get("DoubleJump", false)) else 1
		coyote_timer = COYOTE_TIME
		_update_last_platform()
	else:
		coyote_timer -= delta

	var up_action: String = "move_up_%s" % player_id.to_lower()
	if Input.is_action_just_pressed(up_action):
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
			var wall_normal: float = get_wall_normal().x
			velocity.y = JUMP_VELOCITY
			velocity.x = WALL_JUMP_PUSH * sign(wall_normal)
			jumps_left = 2 if Global.sapphire_collected or (Global.gamemode == "only_up" and Global.upgrades.get("DoubleJump", false)) else 1
			_play_jump_sound()

	var left_action: String = "move_left_%s" % player_id.to_lower()
	var right_action: String = "move_right_%s" % player_id.to_lower()
	var direction: float = Input.get_axis(left_action, right_action)

	animated_sprite.flip_h = direction < 0

	if is_on_floor():
		animated_sprite.play("idle" if direction == 0.0 else "move")
	else:
		animated_sprite.play("jump")

	velocity.x = direction * SPEED if direction != 0.0 else move_toward(velocity.x, 0.0, SPEED)
	move_and_slide()

	_check_respawn()

func _update_last_platform() -> void:
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		if collision.get_normal().y < -0.7 and collision.get_collider() is Node2D:
			var new_platform_pos = collision.get_position()
			if new_platform_pos.y < last_platform_position.y - 10.0:
				platforms_climbed += 1
				_update_climb_display()
			last_platform_position = new_platform_pos
			respawn_position = last_platform_position
			break

func _update_climb_display() -> void:
	if climb_label:
		climb_label.text = "[%d/%d]" % [platforms_climbed, total_platforms]
	else:
		print("⚠️ Climb label not assigned for %s" % player_id)

func _check_respawn() -> void:
	if respawn_cooldown > 0.0:
		return

	if global_position.y - last_platform_position.y > RESPAWN_THRESHOLD:
		is_respawning = true
		global_position = respawn_position
		velocity = Vector2.ZERO
		respawn_cooldown = 0.5
		is_respawning = false

func _play_jump_sound() -> void:
	if jump_sound and jump_sound.stream:
		if jump_sound.playing:
			jump_sound.stop()
		jump_sound.play()

func _load_dino_animations(dino: String) -> void:
	var base_path: String = "res://assets/sprites/dinos/male/%s/base/" % dino
	var animations: Array[String] = ["idle", "move", "jump"]
	var frames: SpriteFrames = SpriteFrames.new()

	for anim in animations:
		var file_path: String = base_path + "%s.png" % anim
		if not ResourceLoader.exists(file_path):
			continue
		var tex: Texture2D = load(file_path)
		var frame_size: int = tex.get_height()
		var frame_count: int = tex.get_width() / frame_size

		if frame_count < 1:
			continue

		frames.add_animation(anim)
		for i in range(frame_count):
			var region: Rect2 = Rect2(i * frame_size, 0, frame_size, frame_size)
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = region
			frames.add_frame(anim, atlas)

	animated_sprite.frames = frames
	animated_sprite.play("idle")

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
			JUMP_VELOCITY *= 1.0 + (0.3 * boost_level)
	if Global.gamemode == "2p":
		SPEED *= 1.75
		JUMP_VELOCITY *= 1.75

func set_platforms(data: Array) -> void:
	total_platforms = data.size()
	for item in data:
		var scene: PackedScene = item["scene"]
		var position: Vector2 = item["position"]
		var platform: Node2D = scene.instantiate()
		platform.position = position
		add_child(platform)

func win_game():
	pass

func set_player_id(id: String) -> void:
	player_id = id

func initialize_player() -> void:
	var raw_selection: String = Global.selected_players.get(player_id, "KuroButton")
	if raw_selection == "" or raw_selection == null:
		raw_selection = "KuroButton"
	var selected_dino: String = raw_selection.replace("Button", "").to_lower()
	_load_dino_animations(selected_dino)
