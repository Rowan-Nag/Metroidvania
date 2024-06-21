extends Node2D
# Called when the node enters the scene tree for the first time.
var time : float = 1.0
var text : String = ""
var textColor : Color = Color.WHITE
var shouldFollowParent : bool = true

@onready var anims : AnimationPlayer = $containerAnimationPlayer
@onready var textLabel : Label = $container/text
@onready var container : Node2D = $container

func _ready():
	await_death()
	anims.play("textMoveAndHide")
	anims.speed_scale = 1.0 / time
	textLabel.label_settings.font_color = textColor
	textLabel.text = text
	if not shouldFollowParent:
		var pos = global_position
		top_level = true
		position = pos

func await_death():
	await get_tree().create_timer(time).timeout
	if (is_instance_valid(self)):
		queue_free()
