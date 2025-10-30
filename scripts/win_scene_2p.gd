extends Node2D

@onready var winner_label: Label = $CanvasLayer/WinnerLabel
@onready var winner_time_label: Label = $CanvasLayer/WinnerTimeLabel
@onready var loser_label: Label = $CanvasLayer/LoserLabel
@onready var loser_time_label: Label = $CanvasLayer/LoserTimeLabel
@onready var back_button: Button = $CanvasLayer/BackButton

func _ready() -> void:
	# Display winner info
	winner_label.text = "%s Wins!" % Global.winner_id
	winner_time_label.text = "Time: %.2fs" % Global.winner_time

	# Display loser info (smaller font)
	loser_label.text = "%s Lost" % Global.loser_id
	loser_time_label.text = "Time: %.2fs" % Global.loser_time

	# Connect button
	back_button.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_screen.tscn")
