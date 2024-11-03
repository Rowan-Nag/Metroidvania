extends StaticBody2D

@onready var anims : AnimationPlayer = $lamp_animationplayer
@onready var animation_list : PackedStringArray  = anims.get_animation_list()

@export var is_on : bool = false
var is_broken : bool = false

func _ready():
	Global.flicker_all_lights.connect(flicker_nonplayer)
	if is_on:
		flicker_on()
	
func flicker_on():
	var anim : String = animation_list[randi_range(0, 3)]
	var animSpeed = randf_range(0.8, 1.2)
	anims.play(anim)
	anims.speed_scale = animSpeed
	is_on = true

func flicker_off():
	var anim : String = animation_list[randi_range(0, 3)]
	var animSpeed = randf_range(0.8, 1.2)
	anims.play_backwards(anim)
	anims.speed_scale = animSpeed
	is_on = false
	
func flicker_nonplayer():
	if is_broken: return
	if is_on:
		flicker_on()
	else:
		flicker_off()

func take_damage(damage, type):
	flicker_off()
	Global.screen_shake(2, 4, 4)
	anims.speed_scale *= 3
	is_broken = true
	$lamp_break_particles.emitting = true
	$lamp_hitbox.set_deferred("disabled", true)

func _on_lamp_detector_body_entered(body):
	if not is_on and not is_broken:
		flicker_on()
