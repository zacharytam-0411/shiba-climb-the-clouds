extends Area2D
@onready var destPoint = $DestinationPoint

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		Global.deaths += 1
		body.position = destPoint.position
		body.velocity = Vector2.ZERO
