extends Control

@onready var master_volume : HSlider = $Container/Master_Volume_Slider
@onready var music_volume : HSlider = $Container/Music_Volume_Slider
@onready var effects_volume : HSlider = $Container/Effects_Volume_Slider

func _ready():
	hide()
	master_volume.ratio = 0.5
	music_volume.ratio = 1.0
	effects_volume.ratio = 1.0
	_update_audio()
	
func _update_audio():
	AudioServer.set_bus_volume_db(0, linear_to_db(master_volume.ratio))
	AudioServer.set_bus_volume_db(1, linear_to_db(music_volume.ratio))
	AudioServer.set_bus_volume_db(2, linear_to_db(effects_volume.ratio))


func _on_volume_slider_changed(_val):
	_update_audio()

	
