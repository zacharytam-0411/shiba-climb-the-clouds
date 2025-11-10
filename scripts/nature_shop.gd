extends Control

@onready var kuro_text: Label = $CanvasLayer/KuroText
@onready var shiba_text: Label = $CanvasLayer/ShibaText
@onready var credits: Label = $CanvasLayer/Credits


func _ready() -> void:
	TranslationServer.set_locale(Global.game_lang)
	Global.update_fonts(self)
	kuro_text.text = tr("kuro_text")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("action_p"):
		var new_locale := "jp" if TranslationServer.get_locale() == "en" else "en"
		Global.game_lang = new_locale
		TranslationServer.set_locale(new_locale)
		Global.update_fonts(self)
