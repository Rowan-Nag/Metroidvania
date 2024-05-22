extends State

var ground_state: State
var jump_state: State
var dash_state: State
var attack_state : State
var wallcling_state : State

@export var gravityMultiplier: float = 1
@export var dragMultiplier: float = 1
@export var accelerationMultiplier: float = 1
@export var moveSpeedMultiplier: float = 1

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * gravityMultiplier


var inputDir: float

func enter() -> void:
	ground_state = parent.ground_state
	jump_state = parent.jump_state
	dash_state = parent.dash_state
	attack_state = parent.attack_state
	#print(ground_state)
	wallcling_state = parent.wallcling_state
	play_animation("fall") # fall
	super()

func process_input(event: InputEvent) -> State:
	if Input.is_action_just_pressed('Dash'):
		return dash_state
	if Input.is_action_just_pressed("Attack") and parent.attackCooldown.is_stopped():
		return attack_state
	if Input.is_action_just_pressed("Rocket"):
		return parent.shoot_state
	
	
	return null

func process_physics(delta: float) -> State:
	#Physics
	var drag = parent.drag * dragMultiplier
	var acceleration = parent.acceleration*accelerationMultiplier
	var maxSpeed = parent.moveSpeed * moveSpeedMultiplier
	
	inputDir = Input.get_axis("Left", "Right")
	
	
	
	if(inputDir):
		
		parent.velocity.x = move_toward(parent.velocity.x, inputDir*maxSpeed, acceleration*delta)
	else:
		parent.velocity.x = move_toward(parent.velocity.x, 0, drag*delta)
	
	#Gravity (vertical movement)
	parent.velocity.y += gravity*gravityMultiplier*delta
	parent.velocity.y = clamp(parent.velocity.y, -10000, parent.terminal_velocity)
	
	parent.move_and_slide()
	
	# Animations
	if(inputDir != 0):
		parent.animations.scale.x = sign(inputDir)*abs(parent.animations.scale.x)
	#if(inputDir == 0):
		#play_animation("idle")
	#else:
		#play_animation("walk")
		#parent.animations.scale.x = sign(inputDir)*abs(parent.animations.scale.x)
	
	# State switches
	if(inputDir != 0 and parent.wallClingCooldown.is_stopped()):
		var canWalljump = parent.getAdjacentWalls()
		#print(canWalljump.left)
		if((canWalljump.left and inputDir < 0) or (canWalljump.right and inputDir > 0)):
			return wallcling_state
	
	if parent.is_on_floor():
		return ground_state
	return null
