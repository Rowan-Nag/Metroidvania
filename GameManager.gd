class_name  GameManager
extends CanvasLayer

@export var current_scene : Node2D
@onready var fade_animation_player : AnimationPlayer = $LoadingScreen/Fade_AnimationPlayer

var last_safe_position : Vector2 = Vector2.ZERO

func _ready():
	Global.Game = self;

func load_new_scene(new_scene_path : String, door_name : String):
	var new_scene : PackedScene = ResourceLoader.load(new_scene_path)
	if(new_scene):
		# Fade Out
		fade_animation_player.play("fade_out")
	
		await fade_animation_player.animation_finished

		get_tree().paused = true # pause game

		# After screen is hidden, switch scenes
		print("switching from " + current_scene.name)
		current_scene.queue_free()
		current_scene = new_scene.instantiate()
		add_child(current_scene)
		print(" to " + current_scene.name)
		#Fade back in
		var door = current_scene.find_child(door_name)
		Global.player.position = door.exit_marker.global_position
		
		#print(Global.player.position)
		get_tree().paused = false
		await  get_tree().create_timer(0.05).timeout
		await get_tree().physics_frame
		Global.player.snap_to_ground(30)
		Global.activeCamera.reset_smoothing()
		fade_animation_player.play("fade_in")



func reset_player_to_checkpoint():
	Global.player.global_position = last_safe_position
	Global.player.velocity = Vector2.ZERO
	print("RESET PLAYER POSITION")

func modulate_foreground(modulation : Color):
	var foreground = find_child('Foreground')
	if is_instance_valid(foreground):
		foreground.modulate = modulation
		
func modulate_background(modulation : Color):
	var background = find_child('Background')
	if is_instance_valid(background):
		background.modulate = modulation
