extends Label

var message_queue: Array = []  # untyped so we can store dictionaries
var showing: bool = false
var active_tween: Tween

func _ready() -> void:
	add_to_group("message_ui")

func show_message(msg: String, duration: float = 2.0) -> void:
	# Add new message to the queue
	message_queue.append({"msg": msg, "duration": duration})
	if not showing:
		_process_queue()

func _process_queue() -> void:
	if message_queue.is_empty():
		showing = false
		return

	showing = true
	var item = message_queue.pop_front()
	self.text = item["msg"]
	visible = true
	modulate.a = 1.0

	# Kill old tween if needed
	if active_tween and active_tween.is_valid():
		active_tween.kill()

	active_tween = create_tween()
	active_tween.tween_interval(item["duration"])
	active_tween.tween_property(self, "modulate:a", 0.0, 0.5)
	active_tween.tween_callback(func():
		visible = false
		_process_queue()
	)
