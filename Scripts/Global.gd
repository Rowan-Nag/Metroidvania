extends Node

var player : Player
var activeCamera : ControllableCamera
var debug : DebugUI
var Game : GameManager
var hudController : HudController

var attackProfiles : Dictionary

var camera_shake = preload("res://Level Scenes/Helper Scenes/camera_shake.tscn")
var alert_text = preload("res://Level Scenes/Helper Scenes/temporary_text_alert.tscn")

func _ready():
	load_attack_profiles()

func set_debug_text(text):
	if(debug):
		debug.add_text(text)
		
func screen_shake(strength : float = 10, decay : float = 6, speed : float = 3):
	var shaker = camera_shake.instantiate()
	shaker.shake_strength = strength
	shaker.shake_decay_rate = decay
	shaker.shake_speed = speed
	activeCamera.add_child(shaker)

func get_text_alert(text : String = "No alert text set!", color : Color = Color.WHITE, time : float = 1.0):
	var alert = alert_text.instantiate()
	
	alert.time = time
	alert.textColor = color
	alert.text = text
	alert.shouldFollowParent = true
	
	return alert

func text_alert(text : String = "No alert text set!", color : Color = Color.WHITE, time : float = 1.0):
	var alert = alert_text.instantiate()
	
	alert.time = time
	alert.textColor = color
	alert.text = text
	alert.shouldFollowParent = true
	
	player.add_child(alert)

func load_attack_profiles():
	var json_string = FileAccess.get_file_as_string('res://Data/attack_profiles.json')
	attackProfiles = JSON.parse_string(json_string)
