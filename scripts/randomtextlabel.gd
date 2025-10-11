extends Label

var random_messages := [
	"Zac zoomed past the clouds! [with what? -zac]",
	"Mort tripped on a trampoline.",
	"Olaf went to visit Shiba.",
	"Mono broke the sound barrier.",
	"Krussy got lost in space.",
	"Shiba barked at the moon.",
	"Teto invented Miku [?].",
	"Loki got teleported into a cave.",
	"Kuro ate 42 pancakes mid-air. [those were mine! -zac]",
	"Press T to Listen to Teto!"
]

func _ready() -> void:
	text = random_messages[randi() % random_messages.size()]
