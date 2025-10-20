extends Control

@onready var title_label: Label = $TitleLabel
@onready var subtitle_label: Label = $SubtitleLabel

func _ready() -> void:
	visible = false  # Hide popup by default when scene loads

func show_milestone(level: int, height: int, message: String) -> void:
	print("MilestonePopup activated: Level %d — %dm — %s" % [level, height, message])

	title_label.text = "Level %d Reached — %dm" % [level+1, height/16]
	subtitle_label.text = message
	visible = true

	# Reset alpha for fade-in
	title_label.modulate.a = 0.0
	subtitle_label.modulate.a = 0.0

	var tween := create_tween()
	tween.tween_property(title_label, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(subtitle_label, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE)

	await get_tree().create_timer(2.5).timeout

	tween = create_tween()
	tween.tween_property(title_label, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(subtitle_label, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE)

	await tween.finished
	visible = false
