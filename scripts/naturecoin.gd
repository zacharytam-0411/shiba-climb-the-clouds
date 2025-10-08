extends Area2D
signal nature_coin_collected
@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		var temp_audio = audio_stream_player.duplicate()
		get_tree().root.add_child(temp_audio)
		temp_audio.global_position = global_position
		temp_audio.play()
		
		Global.only_up_coins += 1
		_add_nature_coin_message()
		emit_signal("nature_coin_collected")
		queue_free()

func _add_nature_coin_message() -> void:
	var msg_node = get_tree().get_first_node_in_group("coin_ui")
	if msg_node:
		msg_node.add_coin(1)
