extends StaticBody2D

@onready var anims : AnimationPlayer = $lamp_animationplayer
@onready var animation_list : PackedStringArray  = anims.get_animation_list()
@onready var lamp_buzz : AudioStreamPlayer2D = $lamp_buzz
@onready var lamp_shatter : AudioStreamPlayer2D = $lamp_shatter

@onready var sprite : Sprite2D = $lamp_sprite
@onready var light : PointLight2D = $PointLight2D

@export var buzz_sound : AudioStream
@export var shatter_sound : AudioStream

@export var is_on : bool = false
var is_broken : bool = false

func _ready():
	Global.flicker_all_lights.connect(flicker_nonplayer)
	
	lamp_buzz.stream = buzz_sound
	lamp_shatter.stream = shatter_sound
	
	if is_on:
		flicker_on()
	
func flicker_on(speed : float = 1):
	var anim : String = animation_list[randi_range(0, 3)]
	var animSpeed = randf_range(0.8, 1.2)
	anims.play(anim)
	anims.speed_scale = animSpeed * speed
	is_on = true
	

func flicker_off(speed : float = 1):
	var anim : String = animation_list[randi_range(0, 3)]
	var animSpeed = randf_range(0.8, 1.2)
	anims.play_backwards(anim)
	anims.speed_scale = animSpeed * speed
	is_on = false
	
func flicker_nonplayer():
	if is_broken: return
	if is_on:
		off()
		flicker_on()
	else:
		on()
		flicker_off()

func on():
	sprite.frame = 0
	light.visible = true
	lamp_buzz.play()

func off():
	sprite.frame = 1
	light.visible = false
	lamp_buzz.stop()

func take_damage(damage, type):
	flicker_off(2)
	Global.screen_shake(2, 4, 4)
	is_broken = true
	lamp_shatter.play()
	$lamp_break_particles.emitting = true
	$lamp_hitbox.set_deferred("disabled", true)

func _on_lamp_detector_body_entered(body):
	if not is_on and not is_broken:
		flicker_on()
		return
