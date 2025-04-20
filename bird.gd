extends Area2D

func _ready():
	pass
	
func _process(delta):
	position.x -= get_parent().speed / 2
