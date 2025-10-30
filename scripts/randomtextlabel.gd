extends Label  # or RichTextLabel

@export var english_font_file: FontFile
@export var japanese_font_file: FontFile

var english_messages := [
	"Something zoomed past the clouds.",
	"Mort bought everything in the shop.",
	"Also try axtro!",
	"Also try ShibaRunner!",
	"Also try Cook or Cooked!",
	"Also try Skullward!",
	"Also try Shogai Run!",
	"Well, whats my birthday?",
	"Kuro ate 42 pancakes mid-air. [Those were mine! - Zac]",
	"Press T to Listen to the TETO-rial!",
	"We are NOT sleeping in shiba - Zac",
	"Nominate yourself for the Shiba Awards!",
    "Don't quit the game.. don't you dare."
]

var selected_english_text: String = ""  # Holds the chosen message for this scene

func _ready():
	add_to_group("translatable")

	# Only choose a new message if one hasn't been picked yet
	if selected_english_text == "":
		selected_english_text = english_messages[randi() % english_messages.size()]

	update_text()

func update_text():
	var lang := Global.current_language
	var translated: String = Global.translations.get(lang, {}).get(selected_english_text, selected_english_text)
	text = translated

	var font := japanese_font_file if lang == "jp" else english_font_file
	add_theme_font_override("font", font)
