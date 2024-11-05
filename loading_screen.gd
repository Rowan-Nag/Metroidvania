extends ColorRect

@onready var fade_anims : AnimationPlayer = $Fade_AnimationPlayer

func _ready():
	Global.fade_in.connect(fade_in)
	Global.fade_out.connect(fade_out)
	
func fade_out():
	process_mode = PROCESS_MODE_ALWAYS
	fade_anims.play("fade_out")

func fade_in():
	fade_anims.play("fade_in")
	await fade_anims.animation_finished
	process_mode = PROCESS_MODE_DISABLED
