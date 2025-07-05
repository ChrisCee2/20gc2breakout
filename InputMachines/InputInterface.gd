class_name InputInterface extends Node

var isPressingUp = false
var isPressingDown = false

func update() -> void:
	return

func getDirection() -> int:
	var direction: int = 0
	if isPressingUp:
		direction -= 1
	if isPressingDown:
		direction += 1
	return direction
