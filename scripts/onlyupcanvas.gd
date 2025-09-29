extends CanvasLayer
@onready var coin_bar: HBoxContainer = $CoinBar
@onready var coins_text: Label = $CoinBar/CoinsText

func _process(delta: float) -> void:
	update_coins()
	
	
func update_coins():
	coins_text.text = "x " + str(Global.only_up_coins)
