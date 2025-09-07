extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body.is_in_group("Player"):
		if Global.diamond_collected == true and Global.ruby_collected == true and Global.sapphire_collected == true and Global.coin == 26:
			print("got flag and win game")
		else:
			print("Go collect all of the coins and gems!")
