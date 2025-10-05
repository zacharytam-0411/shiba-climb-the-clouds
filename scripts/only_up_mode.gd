extends Node2D

@onready var y_label: Label = $CanvasLayer/YLevelLabel
@onready var options_menu: CanvasLayer = $OptionsMenu
@onready var shop_menu: CanvasLayer = $ShopMenu

func _ready() -> void:
	options_menu.visible = false
	shop_menu.visible = false

func _process(_delta: float) -> void:
	y_label.text = "Y Level: %dm" % Global.y_level

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_options_menu()
	elif event.is_action_pressed("open_shop"):
		_toggle_shop_menu()

func _toggle_options_menu() -> void:
	if shop_menu.visible:
		shop_menu.visible = false
	options_menu.visible = !options_menu.visible
	get_tree().paused = options_menu.visible

func _toggle_shop_menu() -> void:
	if options_menu.visible:
		options_menu.visible = false
	shop_menu.visible = !shop_menu.visible
	get_tree().paused = shop_menu.visible




# the options menu works just fine
# now ill show you the shop menu [which only consists of a resume button rn[
# im already clicking intensively and it doesn twork.
