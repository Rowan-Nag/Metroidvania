extends Node

@export var sounds : Array[AudioStream]
var finished = false
func _process(delta):
	if (Input.is_anything_pressed() and not finished):
		finished = true
		for sound : AudioStream in sounds:
			$AudioStreamPlayer.stream = sound
			$AudioStreamPlayer.play()
			print("preloaded audio")
			await get_tree().create_timer(0.5).timeout
		queue_free()
