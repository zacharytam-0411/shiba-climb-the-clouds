extends ColorRect

@onready var dest_point: Marker2D = $"../../Void/DestinationPoint"
var shader_mat: ShaderMaterial
var active_tween: Tween

func _ready() -> void:
	# Make sure the ColorRect itself won't multiply the shader to black
	color = Color(1, 1, 1, 1)
	visible = true

	# Ensure it stretches to cover the viewport
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Grab the material (must be a ShaderMaterial assigned in the inspector)
	shader_mat = material as ShaderMaterial
	if not shader_mat:
		push_warning("FadeOverlay: material is not a ShaderMaterial or is null. Assign your shader material to the ColorRect.material property.")

	# Connect to the Void node signal (if present)
	var void_area = get_tree().current_scene.get_node_or_null("Void")
	if void_area and void_area.has_signal("player_died"):
		void_area.player_died.connect(_on_player_died)


func _on_player_died(player: Node) -> void:
	# Kill any existing tween to prevent overlap / flashing
	if active_tween and active_tween.is_valid():
		active_tween.kill()

	# Always reset visibility and alpha
	visible = true
	modulate.a = 1.0

	var viewport_rect := get_viewport_rect()
	var screen_center := viewport_rect.size * 0.5
	var screen_pos: Vector2

	var cam := get_viewport().get_camera_2d()
	if cam:
		var cam_xform := cam.get_global_transform()
		var local_pos: Vector2 = cam_xform.affine_inverse() * player.global_position
		screen_pos = local_pos + screen_center
	else:
		screen_pos = player.global_position

	# Reset shader parameters
	if shader_mat:
		shader_mat.set_shader_parameter("center", screen_pos)
		shader_mat.set_shader_parameter("radius", 0.0)

	var max_radius := viewport_rect.size.length()
	active_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Step 1: start with full black (alpha = 1, radius = 0 → fully black screen)
	shader_mat.set_shader_parameter("radius", 0)
	modulate.a = 1.0

	# Step 2: short delay with full black
	active_tween.tween_interval(0.1)

	# Step 3: small clear circle appears around player
	active_tween.tween_callback(func(): shader_mat.set_shader_parameter("radius", 100.0))

	# Step 4: keep small circle for a while
	active_tween.tween_interval(0.4)

	# Step 5: expand circle to reveal whole screen
	active_tween.tween_method(Callable(self, "_set_radius"), 100.0, max_radius, 1.0)

	# Step 6: fade overlay out completely
	active_tween.tween_property(self, "modulate:a", 0.0, 0.5)
	active_tween.tween_callback(Callable(self, "_on_fade_complete"))


func _set_radius(v: float) -> void:
	if shader_mat:
		shader_mat.set_shader_parameter("radius", v)


func _on_fade_complete() -> void:
	visible = false
