class_name State
extends Node

var parent: Node

func enter() -> void:
	pass

func exit() -> void:
	pass

func process_input(event: InputEvent) -> State:
	return null

func process_frame(delta: float) -> State:
	return null

func process_physics(delta: float) -> State:
	return null

func play_animation(animation : String) -> void:
	if parent.animations:
		parent.animations.play(animation)
