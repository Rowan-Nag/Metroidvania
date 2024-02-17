extends State

@export var ground_state: State
@export var jump_state: State
@export var dash_state: State
@export var fall_state : State

@export var gravityMultiplier: float = 1
@export var dragMultiplier: float = 1
@export var accelerationMultiplier: float = 1
@export var moveSpeedMultiplier: float = 1

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * gravityMultiplier

@export var horizontal_jump_velocity : int = 300
@export var terminal_velocity : int = 300
var adjacent_wall : int # negative: left wall, positive: right wall

var inputDir: float

func enter() -> void:
	print("Entered!")
	parent.velocity.y = 0

	play_animation("wallcling")
	inputDir = Input.get_axis("Left", "Right")
	adjacent_wall = inputDir
	parent.animations.scale.x = -sign(adjacent_wall)*abs(parent.animations.scale.x)
	super()

func process_input(event: InputEvent) -> State:
	if Input.is_action_just_pressed('Dash'):
		return dash_state
	#if Input.is_action_just_pressed("Attack"): # Can't attack while wall clinging
		#return attack_state 
	if Input.is_action_just_pressed("Jump"):
		parent.velocity.x = -adjacent_wall * horizontal_jump_velocity
		return jump_state
		#Walljump
	
	
	return null

func process_physics(delta: float) -> State:
	#Physics
	var drag = parent.drag * dragMultiplier
	var acceleration = parent.acceleration*accelerationMultiplier
	var maxSpeed = parent.moveSpeed * moveSpeedMultiplier
	
	inputDir = Input.get_axis("Left", "Right")
	
	#Gravity (vertical movement)
	parent.velocity.y += gravity*gravityMultiplier*delta
	parent.velocity.y = clamp(parent.velocity.y, -terminal_velocity, 200)
	
	parent.move_and_slide()
	
	# State switches
	
	if(sign(inputDir) != sign(adjacent_wall)):
		return fall_state
	if parent.is_on_floor():
		return ground_state
	
	return null
