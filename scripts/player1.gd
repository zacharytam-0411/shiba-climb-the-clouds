extends CharacterBody2D

const BASE_SPEED: float = 200.0
const BASE_JUMP_VELOCITY: float = -400.0
const WALL_JUMP_PUSH: float = 200.0
const COYOTE_TIME: float = 0.1
const BASE_GRAVITY: float = 980.0
const RESPAWN_THRESHOLD: float = 240.0  # 2 platforms worth of fall
const JUMP_THRESHOLD: float = 0.5

var SPEED: float = BASE_SPEED
var JUMP_VELOCITY: float = BASE_JUMP_VELOCITY
var coyote_timer: float = 0.0
var jumps_left: int = 1
var respawn_position: Vector2 = Vector2.ZERO
var last_platform_position: Vector2 = Vector2.ZERO
var is_respawning: bool = false
var respawn_cooldown: float = 0.0
var jump_pressed_last_frame: bool = false

@export var player_id: String = "P1"

var finished: bool = false
var finish_time: float = 0.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	randomize()
	add_to_group("player")
	respawn_position = global_position
	last_platform_position = global_position
	_apply_powerups()

func set_player_id(id: String) -> void:
	player_id = id
	initialize_player()

func initialize_player() -> void:
	var raw_selection: String = Global.selected_players.get(player_id, "KuroButton")
	if raw_selection == "" or raw_selection == null:
		raw_selection = "KuroButton"
	var selected_dino: String = raw_selection.replace("Button", "").to_lower()
	_load_dino_animations(selected_dino)

func _physics_process(delta: float) -> void:
	if not is_inside_tree():
		return

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
		last_platform_position = global_position
		respawn_position = global_position
	else:
		coyote_timer -= delta

	# Jump input
	var up_action := "move_up" if player_id == "P1" else "move_up_p2"
	var jump_strength := Input.get_action_strength(up_action)

	var confirm_jump := Input.is_action_just_pressed("confirm_selection") if player_id == "P1" else Input.is_action_just_pressed("unconfirm_selection")
	var jump_pressed := (jump_strength > JUMP_THRESHOLD and not jump_pressed_last_frame) or confirm_jump

	if jump_pressed:
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

	jump_pressed_last_frame = jump_strength > JUMP_THRESHOLD or confirm_jump

	# Horizontal movement
	var left_action := "move_left" if player_id == "P1" else "move_left_p2"
	var right_action := "move_right" if player_id == "P1" else "move_right_p2"
	var direction := Input.get_action_strength(right_action) - Input.get_action_strength(left_action)

	velocity.x = move_toward(velocity.x, direction * SPEED, SPEED * delta * 10)

	if abs(direction) > 0.1:
		animated_sprite.flip_h = direction < 0
		if is_on_floor():
			animated_sprite.play("move")
		else:
			animated_sprite.play("jump")
	else:
		animated_sprite.play("idle")

	move_and_slide()
	_check_respawn()

func _check_respawn() -> void:
	if respawn_cooldown > 0.0:
		return

	if global_position.y - last_platform_position.y > RESPAWN_THRESHOLD:
		is_respawning = true
		velocity = Vector2.ZERO
		global_position = last_platform_position + Vector2(0, -10)
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
	for item in data:
		var scene: PackedScene = item["scene"]
		var position: Vector2 = item["position"]
		var platform: Node2D = scene.instantiate()
		platform.position = position
		add_child(platform)

func win_game(elapsed_time: float) -> void:
	if finished:
		return

	finished = true
	finish_time = elapsed_time
	Global.finished_players[player_id] = finish_time
	print("%s finished in %.2fs" % [player_id, finish_time])

	if Global.finished_players.size() == 2:
		var p1_time = Global.finished_players.get("P1", INF)
		var p2_time = Global.finished_players.get("P2", INF)

		if p1_time < p2_time:
			Global.winner_id = "P1"
			Global.winner_time = p1_time
			Global.loser_id = "P2"
			Global.loser_time = p2_time
		else:
			Global.winner_id = "P2"
			Global.winner_time = p2_time
			Global.loser_id = "P1"
			Global.loser_time = p1_time

		get_tree().change_scene_to_file("res://scenes/win_scene_2p.tscn")
