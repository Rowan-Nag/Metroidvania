class_name DebugUI
extends VBoxContainer

var player : Player

@onready var label : Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.debug = self
	player = Global.player
	label.text = "Player Velocity:"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if(player):
		label.text = "FPS: " + str(Engine.get_frames_per_second()) + "\n"
		label.text += "Player Velocity: " + str(player.velocity) + "\n"
		label.text += "Player State: " + str(player.state_machine.current_state.name)
	else:
		player = Global.player
func add_text(text):
	if(label):
		label.text += "\n"+text
