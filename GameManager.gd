class_name  GameManager
extends CanvasLayer

@export var current_scene : Node2D

var last_safe_position : Vector2 = Vector2.ZERO

var scene_load_thread : Thread
var new_scene : PackedScene
signal scene_has_loaded

func _ready():
	Global.Game = self;

func switch_to_scene(new_scene_path : String, door_name : String):
	if(ResourceLoader.exists(new_scene_path, "PackedScene")):
		# Fade Out
		await fade_out()
	
		get_tree().paused = true # pause game
		scene_load_thread = Thread.new()
		var result = scene_load_thread.start(load_new_scene.bind(new_scene_path))
		if result == ERR_CANT_CREATE:
			load_new_scene(new_scene_path)
		# After screen is hidden, switch scenes
		#print("switching from " + current_scene.name)
		current_scene.queue_free()

		if scene_load_thread.is_alive():
			scene_load_thread.wait_to_finish()
		
		if is_instance_valid(new_scene):
			current_scene = new_scene.instantiate()
		else:
			load_new_scene(new_scene_path)
			current_scene = new_scene.instantiate()
		add_child(current_scene)
		fade_all_audio_in()
		#print(" to " + current_scene.name)
		#Fade back in
		var door = current_scene.find_child(door_name)
		Global.player.position = door.exit_marker.global_position
		
		#print(Global.player.position)

		await get_tree().create_timer(1).timeout
		get_tree().paused = false
		
		await get_tree().physics_frame
		await get_tree().physics_frame
		await get_tree().physics_frame 
		# for some reason, 3 physics frames is the amount it takes for
		# the camerabounds object to instantiate, detect collisions, reset camera limits.

		print(Global.activeCamera.limit_left)
		Global.activeCamera.reset_smoothing()
		Global.player.snap_to_ground(30)
		
		fade_in()



func load_new_scene(new_scene_path : String):
	new_scene = ResourceLoader.load(new_scene_path)
	return
	

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

func fade_out():
	fade_all_audio_out()
	Global.fade_out.emit()
	await get_tree().create_timer(0.2).timeout
	
func fade_in():
	Global.fade_in.emit()
	await get_tree().create_timer(0.1).timeout

func fade_all_audio_out(scene_root : Node = current_scene):
	var audioPlayers : Array[AudioStreamPlayer]
	audioPlayers.assign(scene_root.find_children('*','AudioStreamPlayer',true))
	# get all audioplayers in the new scene
	var audio_fade_tween : Tween = get_tree().create_tween()
	for asp : AudioStreamPlayer in audioPlayers:
		audio_fade_tween.tween_property(asp,'volume_db',-60,1)
		#begin tweening their volumes to 0

func fade_all_audio_in(scene_root : Node = current_scene):
	var audioPlayers : Array[AudioStreamPlayer]
	audioPlayers.assign(scene_root.find_children('*','AudioStreamPlayer',true))
	# get all audioplayers in the new scene
	var audio_fade_tween : Tween = get_tree().create_tween()
	
	for asp : AudioStreamPlayer in audioPlayers:
		var default_vol = asp.volume_db 
		# store the final (default) volume of player
		asp.volume_db = -60 # begin from -60db (inaudible)
		audio_fade_tween.tween_property(asp,'volume_db',default_vol,0.5)
		audio_fade_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		#begin tweening their volumes to the default
		
	
