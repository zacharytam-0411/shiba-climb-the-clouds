extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body.is_in_group("Player"):
		if Global.winnable == true:
			Global.win_level = true
		else:
			Global.win_level = false
	if Global.win_level == true:
		print("you win!")
		get_tree().change_scene_to_file('res://scenes/game_win_scene.tscn')
