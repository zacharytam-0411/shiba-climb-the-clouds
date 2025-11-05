extends Node2D

@onready var y_label: Label = $CanvasLayer/YLevelLabel
@onready var options_menu: CanvasLayer = $OptionsMenu
@onready var shop_menu: CanvasLayer = $ShopMenu

func _ready() -> void:
	TranslationServer.set_locale(Global.game_lang)
	Global.update_fonts(self)
	options_menu.visible = false
	shop_menu.visible = false
	$Player.player_id = "P1"  # or whatever ID is appropriate
	$Player.initialize_player()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("action_p"):
		var new_locale := "jp" if TranslationServer.get_locale() == "en" else "en"
		Global.game_lang = new_locale
		TranslationServer.set_locale(new_locale)

	y_label.text = tr("y_level") + ": %dm" % Global.y_level
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
