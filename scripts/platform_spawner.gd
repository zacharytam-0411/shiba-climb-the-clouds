extends Node2D

@export var platform_scene: PackedScene
@export var player_path: NodePath
@export var vertical_spacing := 50
@export var horizontal_range := 300
@export var spawn_buffer := 600

var player: Node2D
var last_spawn_y := 0.0

func _ready():
	player = get_node(player_path)
	last_spawn_y = player.global_position.y
	spawn_platforms()  

func _process(_delta):
	if player.global_position.y < last_spawn_y - spawn_buffer:
		spawn_platforms()
		last_spawn_y = player.global_position.y

func spawn_platforms():
	for i in range(3):
		var platform = platform_scene.instantiate()
		var x_offset = randf_range(-horizontal_range, horizontal_range)
		var y_offset = randf_range(-vertical_spacing, -vertical_spacing * 2)
		platform.global_position = Vector2(player.global_position.x + x_offset, player.global_position.y + y_offset)
		add_child(platform)
