extends Node

@export var audio : Array[AudioStream]

func _ready():
	for sample : AudioStream in audio:
		AudioServer.register_stream_as_sample(sample)
		print("registered" + str(sample))
		
	await get_tree().process_frame
	queue_free()
