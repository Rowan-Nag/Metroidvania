extends State

@export var fall_state : State
@export var ground_state : State

@export_range(0.1, 4) var attack_rate : float = 1
@export var frames_before_attack : int = 1
@export var frames_after_attack : int = 1

@export var gravityMultiplier: float = 1
@export var floorDragMultiplier: float = 1
@export var airDragMultiplier: float = 1
#@export var accelerationMultiplier: float = 1
#@export var moveSpeedMultiplier: float

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * gravityMultiplier

@onready var attack1 = preload("res://attack1.tscn")
var direction: float = 1
var attackFinished = false

func enter() -> void:
	super()
	ground_state = parent.ground_state
	fall_state = parent.fall_state
	attackFinished = false
	direction = sign(parent.animations.scale.x)
	parent.animations.speed_scale = attack_rate
	play_animation("attack")
	await get_tree().create_timer(frames_before_attack / (12 * attack_rate)).timeout 
	attack()
	await get_tree().create_timer((5 + frames_after_attack) / (12 * attack_rate)).timeout  
	attackFinished = true

func exit() -> void:
	parent.animations.speed_scale = 1 # resetting it to default

func process_input(event: InputEvent) -> State:
	# No inputs while attacking
	
	
	
	
	
	return null

func process_physics(delta: float) -> State:
	#Physics
	var drag = parent.drag
	if(parent.is_on_floor()):
		drag  = parent.drag * floorDragMultiplier
	else:
		drag = parent.drag * airDragMultiplier
		
		
	parent.velocity.x = move_toward(parent.velocity.x, 0, drag*delta)
	
	#Gravity (vertical movement)
	parent.velocity.y += gravity*gravityMultiplier*delta
	parent.velocity.y = clamp(parent.velocity.y, -10000, parent.terminal_velocity)
	
	parent.move_and_slide()
	
	# State switches
	if(attackFinished):
		if(parent.is_on_floor()):
			return ground_state
		else:
			return fall_state
	
	return null
	
	
func attack():
	Global.screen_shake()
	var attack : AnimatedSprite2D = attack1.instantiate()
	attack.speed_scale = attack_rate
	parent.add_child(attack)
	
	if(direction < 0):
		attack.scale.x = -attack.scale.x
		attack.position.x = -20
