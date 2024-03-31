extends State

@export var ground_state : State

@export var gravityMultiplier: float = 1
@export var floorDragMultiplier: float = 1
@export var airDragMultiplier: float = 1
#@export var accelerationMultiplier: float = 1
#@export var moveSpeedMultiplier: float

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * gravityMultiplier

@onready var gunAttack = preload("res://RobotGunAttack.tscn")
@onready var controlAnimation = $AnimationPlayer

@export var postShotAnimationLock : float = 0.3

@export var canShoot = false # when the player can release their shot
@export var animationPaused = false # for pausing/unpausing animation
var finished = false # signals to exit state

var damage = 0
var chargeTimer : SceneTreeTimer # Timer to track how long that attack has been held

func shoot():
	if(animationPaused):
		Global.screen_shake(15, 5, 4)
		animationPaused = false
		var attack = gunAttack.instantiate()
		attack.position = parent.position
		attack.position.x += 15*parent.animations.scale.x
		attack.scale.x = sign(parent.animations.scale.x)
		
		add_child(attack)
		
		var chargeDuration = 10 - chargeTimer.time_left #timer counts down from 10
		
		attack.damage = chargeDuration * damage
		attack.knockbackMultiplier = chargeDuration+1
		attack.scale = Vector2.ONE * (chargeDuration+1)
		
		
		print(chargeTimer.time_left)
		await get_tree().create_timer(postShotAnimationLock).timeout 
		finished = true
		
		
func exitState():
	finished = true

func enter() -> void:
	chargeTimer = get_tree().create_timer(10)
	
	ground_state = parent.ground_state
	
	animationPaused = false # Set tracking variables
	canShoot = false
	finished = false
	
	controlAnimation.seek(0) # Reset to beginning
	controlAnimation.play("PlayerShootAnimation") # Start animation
	
	play_animation("shoot") # Play "shoot" player animation

func exit() -> void:
	controlAnimation.seek(0) # Reset & stop control animationPlayer
	controlAnimation.pause()

func process_input(event: InputEvent) -> State:
	print(!Input.is_action_pressed("Rocket"))
	if (!Input.is_action_pressed("Rocket") and canShoot):
		shoot()
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
	if(animationPaused):
		parent.animations.pause()
	else:
		parent.animations.play()
	# State change for is finished
	if(finished):
		return ground_state
	return null
	

