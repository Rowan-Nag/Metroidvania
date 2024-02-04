class_name PlayerNew
extends CharacterBody2D

@onready
var animations = $AnimatedSprite2D

@onready
var state_machine = $state_machine

@export_category("Physics Components")
@export var drag : int = 400
@export var acceleration : int = 500
@export var moveSpeed : int = 600




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
