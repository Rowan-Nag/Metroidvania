extends Node

var player : Player
var debug : DebugUI

func set_debug_text(text):
	if(debug):
		debug.add_text(text)
