class_name Player
extends CharacterBody2D

@onready
var animations = $AnimatedSprite2D

@onready
var state_machine = $state_machine

@export_category("Physics")
@export var drag : int = 400
@export var acceleration : int = 500
@export var moveSpeed : int = 600
@export var terminal_velocity : int = 1200

@onready var rayLeft : RayCast2D = $RayLeft
@onready var rayRight : RayCast2D = $RayRight
@onready var rayDown : RayCast2D = $RayDown

@export_category("Combat")
@export var maxHealth : int = 4
var health : int = maxHealth
@export var immunityTime : float = 0.2

@export_category("Weight / Knockback")
@export var weight = 10
@export var knockbackMultiplier = 1

@onready var immunity : Timer = $immunityTimer
@onready var jumpBuffer : Timer = $jumpBufferTimer
@onready var attackCooldown : Timer = $AttackCooldown
@onready var wallClingCooldown : Timer = $WallClingCooldown
@onready var fall_state : State = $state_machine/fall
@onready var ground_state : State = $state_machine/ground
@onready var jump_state : State = $state_machine/jump
@onready var dash_state : State = $state_machine/dash
@onready var attack_state : State = $state_machine/attack
@onready var wallcling_state : State = $state_machine/wallcling
@onready var shield_state : State = $state_machine/shield
@onready var shoot_state : State = $state_machine/shoot

@export var jumpBufferTime : float = 0.2

var animationNames

signal took_damage(amount, enemy)
signal death

func grant_immunity(immuneTime):
	immunity.start(immuneTime)

func take_damage(damage : int, knockback, enemy : Enemy = null) -> void:
	if(immunity.is_stopped()):
		took_damage.emit(damage, enemy)
		immunity.start(immunityTime)
		health -= damage
		if (knockback is float):
			knockback(knockback)
		if (knockback is Vector2):
			knockback_vec(knockback)
		state_machine.change_state(fall_state)
		if(health <= 0):
			# Die, probably should emit a signal here saying that the player died.
			death.emit()
			print("Dead.")
		
		if Global.hudController:
			Global.hudController.updateHealthBar()
			Global.hudController.shake(10 * damage)
			Global.screen_shake()

func _ready() -> void:
	# Initialize the state machine, passing a reference of the player to the states,
	# that way they can move and react accordingly
	state_machine.init(self)
	Global.player = self
	animationNames = animations.sprite_frames.get_animation_names()

func _unhandled_input(event: InputEvent) -> void:
	if(Input.is_action_just_pressed("Jump")):
		jumpBuffer.start(jumpBufferTime)
	state_machine.process_input(event)

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)

func _process(delta: float) -> void:
	state_machine.process_frame(delta)

func getAdjacentWalls():
	return {
		"left": rayLeft.is_colliding(),
		"right": rayRight.is_colliding()
	}
	
func jump_buffered() -> bool:
	return not jumpBuffer.is_stopped()

func knockback(direction : float):
	var kbAmt = direction * knockbackMultiplier / weight
	velocity.x = kbAmt
	
	var scaledKb = abs(kbAmt / 50) # Scaling it down so the numbers don't destroy the screen in the next line.
	# SCREEN SHAKER defaults: 10, 6, 3
	Global.screen_shake(scaledKb * 10)

func knockback_vec(direction : Vector2):
	print(direction, knockbackMultiplier, weight)
	velocity = direction * knockbackMultiplier / weight

func play_animation(animationName):
	if(animationNames and animationName in animationNames):
		animations.play(animationName)
