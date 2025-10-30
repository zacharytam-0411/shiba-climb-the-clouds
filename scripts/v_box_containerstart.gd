extends VBoxContainer

@export var english_font_file: FontFile
@export var japanese_font_file: FontFile

# These are the English keys for each button's label
@export var button_keys := {
	"StartButton": "Start Game",
	"SettingsButton": "Options",
	"ShopButton": "Shop",
	"ExitButton": "Exit"
}

func _ready():
	add_to_group("translatable")
	update_buttons()
	
func update_text():
	update_buttons()


func update_buttons():
	var lang := Global.current_language
	var font := japanese_font_file if lang == "jp" else english_font_file

	for button_name in button_keys.keys():
		var button: Button = get_node(button_name)
		var english_text: String = button_keys[button_name]
		var translated: String = Global.translations.get(lang, {}).get(english_text, english_text)

		button.text = translated
		button.add_theme_font_override("font", font)
