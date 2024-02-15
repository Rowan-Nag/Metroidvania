extends State

@export var fall_state: State
@export var dash_state: State
@export var ground_state: State
@export var attack_state : State

@export var gravityMultiplier: float = 1
@export var dragMultiplier: float = 1
@export var accelerationMultiplier: float = 1
@export var moveSpeedMultiplier: float = 1

@export var jump_velocity : int

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * gravityMultiplier

var inputDir: float

func enter() -> void:
	super()
	play_animation("jump")
	parent.velocity.y = -jump_velocity
	
func process_input(event: InputEvent) -> State:
	#if Input.is_action_just_pressed('Dash'):
		#return dash_state
	
	if Input.is_action_just_released("Jump"):
		parent.velocity.y *= 0.6
		return fall_state
	if Input.is_action_just_pressed("Dash"):
		return dash_state
	if Input.is_action_just_pressed("Attack"):
		return attack_state
	
	return null

func process_physics(delta: float) -> State:
	# Physics
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
	
	
	parent.move_and_slide()
	
	# Animations
	#if(inputDir == 0):
		#play_animation("idle")
	#else:
		#play_animation("walk")
		#parent.animations.scale.x = sign(inputDir)*abs(parent.animations.scale.x)
	
	# State switches
	if parent.velocity.y >= 0:
		return fall_state
	return null
