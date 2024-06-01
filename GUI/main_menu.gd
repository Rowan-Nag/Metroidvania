extends Control


func _ready():
	$VBoxContainer/StartButton.grab_focus()

func _on_start_button_pressed():
	print("yes")
	print(get_tree().change_scene_to_file("res://Main.tscn"))
	



func _on_quit_button_pressed():
	get_tree().quit()
