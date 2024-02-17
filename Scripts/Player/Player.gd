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

@export_category("Combat")
@export var maxHealth : int = 100
var health : int = maxHealth
@export var immunityTime : float = 0.2

@onready var immunity : Timer = $immunityTimer

@onready var fall_state : State = $state_machine/fall
@onready var ground_state : State = $state_machine/ground
@onready var jump_state : State = $state_machine/jump
@onready var dash_state : State = $state_machine/dash
@onready var attack_state : State = $state_machine/attack
@onready var wallcling_state : State = $state_machine/wallcling

signal took_damage
signal death

func take_damage(damage : int, knockback : Vector2 = Vector2.ZERO) -> void:
	if(immunity.is_stopped()):
		immunity.start(immunityTime)
		health -= damage
		velocity = knockback*400
		state_machine.change_state(fall_state)
		if(health <= 0):
			# Die, probably should emit a signal here saying that the player died.
			death.emit()
			print("Dead.")
		else:
			took_damage.emit()

func _ready() -> void:
	# Initialize the state machine, passing a reference of the player to the states,
	# that way they can move and react accordingly
	state_machine.init(self)
	Global.player = self

func _unhandled_input(event: InputEvent) -> void:
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
