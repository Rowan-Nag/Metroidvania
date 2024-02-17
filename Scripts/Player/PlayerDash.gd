extends State

var fall_state: State

@export var gravityMultiplier: float = 1
@export var dragMultiplier: float = 1
@export var accelerationMultiplier: float = 1
@export var moveSpeedMultiplier: float = 1

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * gravityMultiplier

var inputDir: float

func enter() -> void:
	var input = Input.get_axis("Left", "Right") 
	fall_state = parent.fall_state
	#print(input)
	parent.velocity.x = sign(input)*900
	parent.velocity.y = 0
	super()
	
	await get_tree().create_timer(0.2).timeout
	parent.velocity.x = sign(input)*50
	

func process_input(event: InputEvent) -> State:
	#if Input.is_action_just_pressed('Dash'):
		#return dash_state
	#if Input.is_action_just_pressed('Jump') and parent.is_on_floor():
		#return jump_state
	
	
	
	
	return null

func process_physics(delta: float) -> State:
	
	parent.velocity.x = move_toward(parent.velocity.x, 0, parent.velocity.x*delta)
	#var acceleration = parent.acceleration*accelerationMultiplier
	#var maxSpeed = parent.moveSpeed * moveSpeedMultiplier
	if(abs(parent.velocity.x) <= 60):
		return fall_state
	parent.move_and_slide()

	return null
