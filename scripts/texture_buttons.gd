extends TextureButton

const TARGET_SIZE: Vector2 = Vector2(6, 6)

func _ready():
	var icon: TextureRect = get_node("Icon")
	if icon and icon.texture:
		var tex_size: Vector2 = icon.texture.get_size()
		if tex_size.x == 0 or tex_size.y == 0:
			return

		var scale_x: float = TARGET_SIZE.x / tex_size.x
		var scale_y: float = TARGET_SIZE.y / tex_size.y
		var uniform_scale: float = min(scale_x, scale_y)

		icon.size = tex_size * uniform_scale
		icon.position = (TARGET_SIZE - icon.size) / 2.0 
		custom_minimum_size = TARGET_SIZE
