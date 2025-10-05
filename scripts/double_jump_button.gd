extends Button

@onready var coin_display: Label = $"../CoinDisplay"

const COST := 25

func _ready():
	_update_state()
	connect("pressed", Callable(self, "_on_pressed"))

func _on_pressed():
	if Global.only_up_coins >= COST and not Global.upgrades["DoubleJump"]:
		Global.only_up_coins -= COST
		Global.upgrades["DoubleJump"] = true
		_update_state()
	else:
		text = "Not Enough Coins!"
		await get_tree().create_timer(1.0).timeout
		_update_state()
		
		
func _process(delta: float) -> void:
	if coin_display:
		coin_display.text = "x %d" % Global.only_up_coins

func _update_state():
	if Global.upgrades["DoubleJump"]:
		text = "Sold Out!"
		disabled = true
	else:
		text = "Purchase"
		disabled = false
