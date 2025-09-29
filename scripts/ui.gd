extends CanvasLayer

@onready var gem_icons = {
	"sapphire": $HUDPanel/VBoxContainer/GemBar/Sapphire,
	"diamond": $HUDPanel/VBoxContainer/GemBar/Diamond,
	"ruby": $HUDPanel/VBoxContainer/GemBar/Ruby,
	"emerald": $HUDPanel/VBoxContainer/GemBar/Emerald
}

@onready var task_bar: ProgressBar = $HUDPanel/VBoxContainer/TaskBar
@onready var lives_bar = $HUDPanel/VBoxContainer/LivesBar
@onready var y_label = $HUDPanel/VBoxContainer/YLevelLabel
@onready var panel_container = $HUDPanel
@onready var lives_text: Label = $HUDPanel/VBoxContainer/LivesBar/LivesText
@onready var coins_text: Label = $HUDPanel/VBoxContainer/CoinBar/CoinsText
@onready var end_flag: Area2D = $"../Flag"
@onready var end_arrow: Sprite2D = $HUDPanel/EndArrow
@export var player_path: NodePath
var player_ref: Node2D
var diamond_was_collected := false

func _ready() -> void:
	player_ref = get_node(player_path)
	task_bar.set_custom_minimum_size(Vector2(200, 16))

func _process(_delta: float) -> void:
	update_gems()
	update_coins()
	update_lives()
	update_y_level()
	if Global.winnable:
		var direction = (end_flag.global_position - player_ref.global_position).normalized()
		end_arrow.rotation = direction.angle() + PI/2
		end_arrow.visible = true
	else:
		end_arrow.visible = false
	if Global.diamond_collected and not diamond_was_collected:
		diamond_was_collected = true
		animate_heart_upgrade()


func update_gems():
	gem_icons["sapphire"].modulate = Color.WHITE if Global.sapphire_collected else Color(1, 1, 1, 0.3)
	gem_icons["diamond"].modulate = Color.WHITE if Global.diamond_collected else Color(1, 1, 1, 0.3)
	gem_icons["ruby"].modulate = Color.WHITE if Global.ruby_collected else Color(1, 1, 1, 0.3)
	gem_icons["emerald"].modulate = Color.WHITE if Global.emerald_collected else Color(1, 1, 1, 0.3)

func update_coins():
	# Update coin count label
	coins_text.text = "x " + str(Global.coin) + "/32"

	# Calculate gem progress
	var gem_progress := 0.0
	if Global.sapphire_collected:
		gem_progress += 12.5
	if Global.diamond_collected:
		gem_progress += 12.5
	if Global.ruby_collected:
		gem_progress += 12.5
	if Global.emerald_collected:
		gem_progress += 12.5

	# Calculate coin progress
	var coin_progress:float = clamp(Global.coin, 0, 32) * (50.0 / 32.0)

	# Total task progress
	var total_progress:float = gem_progress + coin_progress

	# Update task bar
	task_bar.value = total_progress
	task_bar.max_value = 100
func update_lives():
	var heart_texture = preload("res://assets/sprites/hearticon.png")
	var diamond_texture = preload("res://assets/sprites/goldhearticon.png")

	var heart = lives_bar.get_node("Heart")
	if Global.diamond_collected:
		heart.texture = diamond_texture
	else:
		heart.texture = heart_texture
	lives_text.text = "x " + str(Global.lives)

func animate_heart_upgrade():
	var heart = lives_bar.get_node("Heart")
	var tween = create_tween()
	tween.tween_property(heart, "scale", Vector2(1.4, 1.4), 0.2).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(heart, "scale", Vector2(0.98, 0.98), 0.2)


func update_y_level():
	y_label.text = "Y Level: %dm" % Global.y_level
