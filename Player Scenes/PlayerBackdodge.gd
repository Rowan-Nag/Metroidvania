extends State

@export var gravityMultiplier: float = 1
@export var groundDragMultiplier: float = 1
@export var airDragMultiplier : float = 1
@export var accelerationMultiplier: float = 1
@export var moveSpeedMultiplier: float = 1

@export var dodge_velocity : Vector2 = Vector2.RIGHT

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * gravityMultiplier

var is_completely_finished : bool = false
var is_recovering : bool = false
var is_successful_dodge : bool = false
var can_parry : bool = false
@onready var dummyPlayer : Player = $dummyPlayerHitbox
@onready var anims : AnimationPlayer = $backdodgeAnimationPlayer
func enter() -> void:
	anims.play("backdodge")
	disable_dummy_hitbox()
	is_completely_finished = false
	is_recovering = false
	is_successful_dodge = false
	can_parry = false

	play_animation("backdodge-jump") # fall
	parent.velocity = -dodge_velocity
	parent.velocity.x *= sign(parent.animations.scale.x)
	super()
	
	await parent.animations.animation_finished
	if not is_recovering:
		play_animation('backdodge-fall')

func exit() -> void:
	disable_dummy_hitbox()

func process_input(event: InputEvent) -> State:
	
	
	return null

func process_physics(delta: float) -> State:
	#Physics
	var groundDrag = parent.drag * groundDragMultiplier
	var airDrag = parent.drag * airDragMultiplier
	var acceleration = parent.acceleration*accelerationMultiplier
	var maxSpeed = parent.moveSpeed * moveSpeedMultiplier
	

	
	#Gravity (vertical movement)
	parent.velocity.y += gravity*gravityMultiplier*delta
	parent.velocity.y = clamp(parent.velocity.y, -10000, parent.terminal_velocity)
	
	if parent.is_on_floor():
		parent.velocity.x = move_toward(parent.velocity.x, 0, groundDrag * delta)
	else:
		parent.velocity.x = move_toward(parent.velocity.x, 0, airDrag * delta)
	
	parent.move_and_slide()
	
	# Animations
	
	# State switches
	
	if is_completely_finished:
		return parent.ground_state
	
	if parent.is_on_floor() and not is_recovering:
		finish_dodge()
		#return ground_state
	return null

func finish_dodge():
	is_recovering = true
	play_animation('backdodge-recover')
	await parent.animations.animation_finished
	is_completely_finished = true
	
func disable_dummy_hitbox():
	#dummyPlayer.process_mode = Node.PROCESS_MODE_DISABLED
	pass
	
func enable_dummy_hitbox():
	#dummyPlayer.process_mode = Node.PROCESS_MODE_INHERIT
	pass
	

func _on_dummy_player_hitbox_took_damage(amount, enemy):
	Global.text_alert("Dodged!")
	print("dodged")
	can_parry = true
