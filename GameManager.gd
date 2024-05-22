extends CanvasLayer

var current_scene : PackedScene
@onready var fade_animation_player : AnimationPlayer = $LoadingScreen/Fade_AnimationPlayer

var last_safe_position : Vector2 = Vector2.ZERO


func load_new_scene(new_scene : PackedScene):
	
	if(new_scene and new_scene != current_scene):
		# Fade Out
		fade_animation_player.play("fade_out")
	
		await fade_animation_player.animation_finished
		# After screen is hidden, switch scenes
		current_scene.queue_free()
		add_child(new_scene.instantiate())
		current_scene = new_scene
		#Fade back in
		fade_animation_player.play("fade_in")
