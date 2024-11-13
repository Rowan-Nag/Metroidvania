extends Area2D
class_name Interactable

@export var selection_priority = 1 
@export var selected_shader : ShaderMaterial

var original_shader : ShaderMaterial
var parent : CanvasItem
var highlighted = false

signal interacted

func _ready():
	parent = get_parent()
	original_shader = parent.material

func _on_body_entered(body):
	if body is Player:
		body.interactables.append(self)
		recalculate_best_interactable()
		
func _on_body_exited(body):
	if body is Player:
		if highlighted: unhighlight()
		body.interactables.erase(self)
		recalculate_best_interactable()

func recalculate_best_interactable():
	if Global.player.interactables.size() == 0: return
	Global.player.interactables[0].unhighlight()
	Global.player.interactables.sort_custom(compare_interactable)
	Global.player.interactables[0].highlight()

func compare_interactable(other : Interactable) -> bool:
	if other.selection_priority > selection_priority:
		return true
	return ((global_position - Global.player.global_position).length()
			< (other.global_position - Global.player.global_position).length())

func unhighlight():
	print("unhighlight")
	highlighted = false
	parent.material = original_shader
	return false

func highlight():
	print("highlight")
	highlighted = true
	parent.material = selected_shader
	return true

func _exit_tree():
	Global.player.interactables.erase(self)
