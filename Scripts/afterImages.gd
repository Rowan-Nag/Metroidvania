extends Node2D

var interval : float = 0.1
var length : float = 1

var parent_animations : AnimatedSprite2D
var image_scale : Vector2

var decayingAfterImage = preload('res://Player Scenes/decaying_after_image.tscn')
@onready var afterImageTimer : Timer = $afterImageTimer

func await_afterimage_end():
	await get_tree().create_timer(length).timeout
	queue_free()
	
func _ready():
	afterImageTimer.wait_time = interval
	afterImageTimer.start()
	await_afterimage_end()
	
	length -= 0.5 # time for individual afterimage animation to fade out.

func create_afterImage():
	var image_sprite = decayingAfterImage.instantiate()
	image_sprite.position = parent_animations.to_global(parent_animations.position)
	
	var anim = parent_animations.animation
	var idx = parent_animations.frame
	
	image_sprite.texture = parent_animations.sprite_frames.get_frame_texture(anim, idx)
	image_sprite.scale = image_scale
	add_child(image_sprite)
	
func _on_after_image_timer_timeout():
	#print("new afterimage")
	if (length >= 0):
		create_afterImage()
		length -= interval
