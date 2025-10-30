extends Label  # or RichTextLabel

@export var english_text: String = ""
@export var english_font_file: FontFile
@export var japanese_font_file: FontFile

func _ready():
	add_to_group("translatable")
	update_text()

func update_text():
	var lang := Global.current_language
	text = Global.translations.get(lang, {}).get(english_text, english_text)

	var font := japanese_font_file if lang == "jp" else english_font_file
	add_theme_font_override("font", font)
