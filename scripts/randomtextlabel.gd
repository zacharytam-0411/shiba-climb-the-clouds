extends Label

var random_messages := [
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

func _ready() -> void:
	text = random_messages[randi() % random_messages.size()]
