extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect the body_entered signal to the _on_body_entered function
	body_entered.connect(_on_body_entered)

# Function to handle when a body enters the Area2D
func _on_body_entered(body):
	if body.is_in_group("Player"):  # Check if the body is the player
		body.position = ($DestinationPoint.position) # Teleport player to (0, 0)
