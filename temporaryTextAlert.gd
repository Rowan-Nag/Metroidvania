extends Node2D
# Called when the node enters the scene tree for the first time.
var time : float = 1.0
var text : String = ""
var textColor : Color = Color.WHITE
var shouldFollowParent : bool = true

@onready var anims : AnimationPlayer = $container/AnimationPlayer
@onready var textLabel : Label = $container/text

func _ready():
	anims.play("textMoveAndHide")
	anims.speed_scale = 1.0 / time
	textLabel.label_settings.font_color = textColor
	textLabel.text = text
	if not shouldFollowParent:
		var pos = global_position
		top_level = true
		position = pos
		
