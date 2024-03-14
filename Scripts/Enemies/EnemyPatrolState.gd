extends State

@export var alerted_state : State 

@export var start_facing_right: bool = true
@export var alert_distance : int = 400
@export var walkSpeed = 200
@export var waitTime : float = 2

@onready var wallDetector : RayCast2D 
@onready var floorDetector : RayCast2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var waiting = false

func enter() -> void:
	parent.play_animation("walk")
	wallDetector = parent.find_child("wallDetector")
	floorDetector = parent.find_child("floorDetector")
	
	if(has_node("AnimationPlayer")): #If there's an assigned wait animation
		var waitAnim : AnimationPlayer = get_node("AnimationPlayer")
		waitAnim.pause()
		var offset = (randf() * 4)
		print(offset)
		await get_tree().create_timer(offset).timeout #We offset it by 1-2 seconds (at random) to add variation.
		waitAnim.play()
	
	
func exit() -> void:
	pass

#func process_input(event: InputEvent) -> State:
	#return null
#
#func process_frame(delta: float) -> State:
	#return null

func process_physics(delta: float) -> State:
	parent.velocity.y += gravity*delta
	if(not waiting):
		parent.velocity.x = walkSpeed
		
		if(parent.getPlayerDistance() < alert_distance):
			if(alerted_state):
				
				return alerted_state
		
		if(not floorDetector.is_colliding()):
			wait_and_turn()
		if(wallDetector.is_colliding()):
			wait_and_turn()
		
		
	else:
		parent.velocity.x = 0
		parent.play_animation("idle")
		
	parent.handle_knockback(delta)
	parent.move_and_slide()
	return null

func play_animation(animation) -> void:
	if parent.animations:
		parent.animations.play(animation)
		

func wait_and_turn():
	waiting = true
	wallDetector.target_position.x = -wallDetector.target_position.x
	floorDetector.position.x = - floorDetector.position.x
	await get_tree().create_timer(waitTime).timeout
	walkSpeed = -walkSpeed
	parent.animated_sprite.scale.x = -parent.animated_sprite.scale.x
	waiting = false
