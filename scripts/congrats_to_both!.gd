extends RichTextLabel

const COLOR_A := "#6299ff"  # Blue
const COLOR_B := "#ff999a"  # Pink

func _ready() -> void:
	bbcode_enabled = true

	var full_text := "Congrats to both players!!! You both have done a great job!"
	var midpoint := full_text.length() / 2
	var first_half := full_text.substr(0, midpoint)
	var second_half := full_text.substr(midpoint)

	text = "[color=%s]%s[/color][color=%s]%s[/color]" % [COLOR_A, first_half, COLOR_B, second_half]
