extends CanvasLayer

@onready var mat: ShaderMaterial = $OverlayRect.material as ShaderMaterial

func _ready():
	visible = false

# Step 1: Fade to black instantly
func start_reveal(_world_pos: Vector2) -> void:
	visible = true
	mat.set_shader_parameter("radius", 2.0)
	mat.set_shader_parameter("center", Vector2(0.5, 0.5))  # Placeholder center

# Step 2: Reveal clear circle from respawn point in OnlyUpMode
func reveal_circle(world_pos: Vector2) -> void:
	var camera := get_viewport().get_camera_2d()
	var screen_size: Vector2 = get_viewport().size
	var screen_pos: Vector2 = world_pos - (camera.global_position - screen_size / 2)
	var normalized_center: Vector2 = screen_pos / screen_size

	mat.set_shader_parameter("center", normalized_center)
	mat.set_shader_parameter("radius", 0.0)
	mat.set_shader_parameter("softness", 0.1)

	var tween := create_tween()
	tween.tween_method(
		func(r): mat.set_shader_parameter("radius", r),
		0.0, 2.0, 1.5
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.finished.connect(func(): visible = false)
