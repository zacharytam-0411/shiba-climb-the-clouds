extends Node

@onready var options_menu: CanvasLayer = $OptionsMenu
@onready var fade_overlay: ColorRect = $CanvasLayer/FadeOverlay  # <-- Correct path

func _ready() -> void:
	options_menu.visible = false
	fade_overlay.modulate = Color(0, 0, 0, 0)  # start transparent
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):  # ESC key
		_toggle_options_menu()

func _toggle_options_menu() -> void:
	if options_menu.visible:
		options_menu.visible = false
		get_tree().paused = false
	else:
		options_menu.visible = true
		get_tree().paused = true

# --- Respawn system ---
func respawn_player(player: Node, target_pos: Vector2):
	var tween = create_tween()
	# Fade out
	tween.tween_property(fade_overlay, "modulate:a", 1.0, 0.5)
	tween.tween_callback(Callable(self, "_do_respawn").bind(player, target_pos))
	# Small delay then fade back in
	tween.tween_interval(0.2)
	tween.tween_property(fade_overlay, "modulate:a", 0.0, 0.5)

func _do_respawn(player: Node, target_pos: Vector2):
	player.velocity = Vector2.ZERO
	player.position = target_pos
