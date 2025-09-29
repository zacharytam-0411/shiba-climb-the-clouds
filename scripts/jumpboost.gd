extends Button

const MAX_LEVEL := 5
const BASE_COST := 10

func _ready():
	_update_state()

func _on_pressed():
	var level :int = Global.upgrades.get("JumpBoost", 0)
	var cost :int = BASE_COST * (level + 1)

	if Global.only_up_coins >= cost and level < MAX_LEVEL:
		Global.only_up_coins -= cost
		Global.upgrades["JumpBoost"] += 1
		_update_state()
	else:
		text = "Not Enough Coins!"
		await get_tree().create_timer(1.0).timeout
		_update_state()

func _update_state():
	var level :int = Global.upgrades.get("JumpBoost", 0)

	if level >= MAX_LEVEL:
		text = "Jump Boost [Maxed]"
		disabled = true
	else:
		var cost :int = BASE_COST * (level + 1)
		text = "Jump Boost Lv.%d (%d coins)" % [level + 1, cost]
		disabled = false
