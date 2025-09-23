extends Label

var coin_buffer: int = 0
var buffer_timer: Timer
var active_tween: Tween
var base_offset: Vector2

func _ready() -> void:
	add_to_group("coin_ui")

	# Remember original position (bottom-right offset)
	base_offset = position

	buffer_timer = Timer.new()
	buffer_timer.one_shot = true
	add_child(buffer_timer)
	buffer_timer.timeout.connect(_flush_buffer)

	visible = false

func add_coin(amount: int = 1, buffer_time: float = 1.0) -> void:
	coin_buffer += amount
	_update_display()

	# Restart timer so popup stays while collecting
	buffer_timer.start(buffer_time)

func _update_display() -> void:
	var text_str := "+%d coin%s" % [coin_buffer, "s" if coin_buffer > 1 else ""]
	self.text = text_str
	visible = true
	modulate.a = 1.0
	position = base_offset  # reset each time

	# Cancel any active tween
	if active_tween and active_tween.is_valid():
		active_tween.kill()

func _flush_buffer() -> void:
	if coin_buffer <= 0:
		return

	# Fade + slide upward (relative to bottom-right base offset)
	active_tween = create_tween()
	active_tween.parallel().tween_property(self, "modulate:a", 0.0, 0.5)
	active_tween.parallel().tween_property(self, "position", base_offset + Vector2(0, -30), 0.5)
	active_tween.tween_callback(func():
		visible = false
		coin_buffer = 0
	)
