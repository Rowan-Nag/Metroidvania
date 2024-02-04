extends State

@export var fall_state: State
@export var dash_state: State
@export var ground_state: State

@export var gravityMultiplier: float = 1
@export var dragMultiplier: int = 1
@export var accelerationMultiplier: int = 1
@export var moveSpeedMultiplier: int

@export var jump_velocity : int

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * gravityMultiplier

var inputDir: float

func enter() -> void:
	super()
	parent.velocity.y = -jump_velocity
	
func process_input(event: InputEvent) -> State:
	#if Input.is_action_just_pressed('Dash'):
		#return dash_state
	
	if Input.is_action_just_released("Jump"):
		parent.velocity.y *= 0.6
		return fall_state
	if Input.is_action_just_pressed("Dash"):
		return dash_state
	
	
	return null

func process_physics(delta: float) -> State:
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
	
	if parent.velocity.y >= 0:
		return fall_state
	return null
