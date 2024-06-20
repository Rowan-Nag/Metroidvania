extends Node

var player : Player
var activeCamera : ControllableCamera
var debug : DebugUI
var Game : GameManager
var hudController : HudController

var camera_shake = preload("res://Level Scenes/Helper Scenes/camera_shake.tscn")
var alert_text = preload("res://Level Scenes/Helper Scenes/temporary_text_alert.tscn")

func set_debug_text(text):
	if(debug):
		debug.add_text(text)
		
func screen_shake(strength : float = 10, decay : float = 6, speed : float = 3):
	var shaker = camera_shake.instantiate()
	shaker.shake_strength = strength
	shaker.shake_decay_rate = decay
	shaker.shake_speed = speed
	activeCamera.add_child(shaker)

func text_alert(text : String = "No alert text set!", should_follow_player : bool = true, color : Color = Color.WHITE, time : float = 1.0):
	var alert = alert_text.instantiate()
	
	alert.time = time
	alert.textColor = color
	alert.text = text
	alert.shouldFollowParent = should_follow_player
	
	player.add_child(alert)
