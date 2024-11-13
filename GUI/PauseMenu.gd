extends ColorRect

var settingsOpen : bool = false;
@onready var pauseMenu : Control = $PauseMenu
@onready var settingsMenu : Control = $Settings
var currentMenu : Control = null

func _ready():
	hide()

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			if currentMenu:
				print('yes')
				currentMenu.hide()
				pauseMenu.show()
				currentMenu = null
				return
			
			if (get_tree().paused):
				resume()
			elif (!get_tree().paused):
				pause()
		
func pause():
	show()
	get_tree().paused = true;

func resume():
	get_tree().paused = false;
	hide()

func _on_quit_pressed():
	get_tree().paused = false;
	get_tree().change_scene_to_file('res://GUI/main_menu.tscn')

func _on_resume_pressed():
	resume()

func _on_settings_pressed():
	settingsMenu.show()
	pauseMenu.hide()
	currentMenu = settingsMenu
	print(settingsMenu.visible)
