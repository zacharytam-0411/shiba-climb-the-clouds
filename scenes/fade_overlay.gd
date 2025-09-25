extends ColorRect

@onready var dest_point: Marker2D = $"../../Void/DestinationPoint"
@onready var shader_mat: ShaderMaterial = null
var active_tween: Tween = null

# last known center in screen coordinates (pixels)
var last_screen_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	color = Color(1, 1, 1, 1)
	visible = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	shader_mat = material as ShaderMaterial
	if not shader_mat:
		push_warning("FadeOverlay: material is not a ShaderMaterial or is null. Assign your shader material to the ColorRect.material property.")

	# Connect to player_died if available
	var void_area := get_tree().current_scene.get_node_or_null("Void")
	if void_area and void_area.has_signal("player_died"):
		void_area.player_died.connect(_on_player_died)


func _on_player_died(player: Node) -> void:
	if active_tween and active_tween.is_valid():
		active_tween.kill()

	visible = true
	modulate.a = 1.0

	# --- Respawn position in world space ---
	var spawn_pos: Vector2
	if "respawn_position" in player and player.respawn_position != Vector2.ZERO:
		spawn_pos = player.respawn_position
	else:
		spawn_pos = dest_point.global_position

	# --- Convert world → screen pixels ---
	var vp := get_viewport()
	var canvas_xform: Transform2D = vp.get_canvas_transform()
	last_screen_pos = canvas_xform * spawn_pos
	queue_redraw()  # for debug circle

	# --- Send to shader ---
	if shader_mat:
		shader_mat.set_shader_parameter("center_world", last_screen_pos)
		shader_mat.set_shader_parameter("radius", 0.0)

	var viewport_size: Vector2 = vp.size
	var max_radius: float = viewport_size.length()

	# --- Animate with Tween ---
	active_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	active_tween.tween_interval(0.1)  # small pause
	active_tween.tween_callback(func():
		if shader_mat:
			shader_mat.set_shader_parameter("radius", 100.0)
	)

	active_tween.tween_interval(0.6)
	active_tween.tween_method(Callable(self, "_set_radius"), 100.0, max_radius, 1.0)
	active_tween.tween_property(self, "modulate:a", 0.0, 0.5)
	active_tween.tween_callback(Callable(self, "_on_fade_complete"))


func _set_radius(v: float) -> void:
	if shader_mat:
		shader_mat.set_shader_parameter("radius", v)


func _on_fade_complete() -> void:
	visible = false
	if shader_mat:
		shader_mat.set_shader_parameter("center_world", last_screen_pos)
		shader_mat.set_shader_parameter("radius", 0.0)


func _draw() -> void:
	# Debug: red dot shows where the effect centers
	if last_screen_pos != Vector2.ZERO:
		draw_circle(last_screen_pos, 6, Color(1, 0, 0))
