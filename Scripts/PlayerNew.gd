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

@export_category("Combat")
@export var maxHealth : int = 100
var health : int = maxHealth
@export var immunityTime : float = 0.2

@onready var immunity : Timer = $immunityTimer

func take_damage(damage : int, knockback : Vector2 = Vector2.ZERO) -> void:
	if(immunity.is_stopped()):
		immunity.start(immunityTime)
		health -= damage
		velocity = knockback*400
		if(health <= 0):
			# Die, probably should emit a signal here saying that the player died.
			print("Dead.")


func _ready() -> void:
	# Initialize the state machine, passing a reference of the player to the states,
	# that way they can move and react accordingly
	state_machine.init(self)

func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)

func _physics_process(delta: float) -> void:

	state_machine.process_physics(delta)

func _process(delta: float) -> void:
	state_machine.process_frame(delta)
