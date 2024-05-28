extends Node

var player : Player
var activeCamera : ControllableCamera
var debug : DebugUI

var camera_shake = preload("res://Level Scenes/Helper Scenes/camera_shake.tscn")

func set_debug_text(text):
	if(debug):
		debug.add_text(text)
		
func screen_shake(strength : float = 10, decay : float = 6, speed : float = 3):
	var shaker = camera_shake.instantiate()
	shaker.shake_strength = strength
	shaker.shake_decay_rate = decay
	shaker.shake_speed = speed
	activeCamera.add_child(shaker)
