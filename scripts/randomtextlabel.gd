extends Label

var random_messages := [
	"Zac zoomed past the clouds!",
	"Mort tripped on a trampoline.",
	"Sena found a secret tunnel.",
	"Olaf danced with a Kuro.",
	"Mono broke the sound barrier.",
	"Krussy got lost in space.",
	"Shiba barked at the moon.",
	"Nico invented jet shoes.",
	"Loki teleported into a volcano.",
	"Cole ate 42 pancakes mid-air.",
	"Press P to Listen to Teto!"
]

func _ready() -> void:
	text = random_messages[randi() % random_messages.size()]
