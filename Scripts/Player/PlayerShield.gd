extends State

var ground_state: State


@export var gravityMultiplier: float = 1
@export var dragMultiplier: float = 1
#@export var accelerationMultiplier: float = 1
#@export var moveSpeedMultiplier: float = 1
var shielding = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * gravityMultiplier


var inputDir: float
@onready var shieldParticles : CPUParticles2D = $shieldParticles


func enter() -> void:
	super()
	shieldParticles.position = parent.position
	shieldParticles.emitting = true
	
	shielding = true
	ground_state = parent.ground_state
	play_animation("shield") # fall

	await get_tree().create_timer(0.75).timeout 
	shielding = false

func process_input(event: InputEvent) -> State:
	#if Input.is_action_just_pressed('Dash'):
		#return dash_state
	#if Input.is_action_just_pressed("Attack"):
		#return attack_state
		
	
	
	return null

func process_physics(delta: float) -> State:
	#Physics
	#shieldParticles.position = parent.position
	var drag = parent.drag * dragMultiplier
	#var acceleration = parent.acceleration*accelerationMultiplier
	#var maxSpeed = parent.moveSpeed * moveSpeedMultiplier
	
	inputDir = Input.get_axis("Left", "Right")
	
	
	
	#if(inputDir):
		#
		#parent.velocity.x = move_toward(parent.velocity.x, inputDir*maxSpeed, acceleration*delta)
	#else:
	parent.velocity.x = move_toward(parent.velocity.x, 0, drag*delta)
	
	#Gravity (vertical movement)
	parent.velocity.y += gravity*gravityMultiplier*delta
	parent.velocity.y = clamp(parent.velocity.y, -10000, parent.terminal_velocity)
	
	parent.move_and_slide()
	if(not shielding):
		return ground_state
	# Animations
	if(inputDir != 0):
		parent.animations.scale.x = sign(inputDir)*abs(parent.animations.scale.x)
	
	return null


func _on_player_took_damage(amount, enemy):
	if(shielding):
		parent.grant_immunity(2)
		print("Shielded!")
		if(enemy is Enemy):
			print("Knockback!")
			#print(parent.to_local(enemy.global_position))
			enemy.knockback(sign(parent.to_local(enemy.global_position).x)*1000)
		print("ATTACK SHIELDED")
