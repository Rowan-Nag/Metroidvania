extends State

var ground_state: State
var jump_state: State
var dash_state: State
var fall_state : State

@export var gravityMultiplier: float = 1
@export var dragMultiplier: float = 1
@export var accelerationMultiplier: float = 1
@export var moveSpeedMultiplier: float = 1

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * gravityMultiplier

@export var horizontal_jump_velocity : int = 300
@export var vertical_jump_velocity : int = 200
@export var terminal_velocity : int = 300
var adjacent_wall : int # negative: left wall, positive: right wall

var inputDir: float

func enter() -> void:
	#print("Entered!")
	ground_state = parent.ground_state
	jump_state = parent.jump_state
	dash_state = parent.dash_state
	fall_state = parent.fall_state
	
	parent.velocity.y = 0

	play_animation("wallcling")
	inputDir = Input.get_axis("Left", "Right")
	adjacent_wall = inputDir
	parent.animations.scale.x = -sign(adjacent_wall)*abs(parent.animations.scale.x)
	super()

func process_input(event: InputEvent) -> State:
	if Input.is_action_just_pressed('Dash'):
		return dash_state
	#if Input.is_action_just_pressed("Grapple"):
		#return parent.grapple_state
	#if Input.is_action_just_pressed("Attack"): # Can't attack while wall clinging
		#return attack_state 
	
	return null

func process_physics(delta: float) -> State:
	parent.wallClingCooldown.start()
	#Physics
	var drag = parent.drag * dragMultiplier
	var acceleration = parent.acceleration*accelerationMultiplier
	var maxSpeed = parent.moveSpeed * moveSpeedMultiplier
	
	inputDir = Input.get_axis("Left", "Right")
	
	#Gravity (vertical movement)
	if (Input.is_action_pressed("Jump")):
		parent.velocity.y = 0
		if (Input.is_action_just_pressed("Attack") and parent.attackCooldown.is_stopped()):
			parent.attack_state.attack();
		if (Input.is_action_just_pressed("Rocket")):
			parent.shoot_state.shoot();
	else: 
		parent.velocity.y += gravity*gravityMultiplier*delta
		parent.velocity.y = clamp(parent.velocity.y, -terminal_velocity, 200)
	
	if parent.is_jump_buffered() and Input.is_action_pressed("Jump"):
		parent.velocity.x = -adjacent_wall * horizontal_jump_velocity
		parent.velocity.y = -1 * vertical_jump_velocity
		return fall_state
	
	parent.move_and_slide()
	
	# State switches
	var adjacentWalls = parent.getAdjacentWalls()
	if(adjacent_wall < 0 and not adjacentWalls.left):
		return fall_state
	if(adjacent_wall > 0 and not adjacentWalls.right):
		return fall_state
	if(sign(inputDir) != sign(adjacent_wall)):
		return fall_state
	if parent.is_on_floor():
		return ground_state
	
	return null
