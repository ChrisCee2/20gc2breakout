class_name InputInterface extends Node

var isPressingUp = false
var isPressingDown = false
var isPressingLeft = false
var isPressingRight = false

func update() -> void:
	return

func getDirection() -> int:
	var direction: int = 0
	if isPressingLeft:
		direction -= 1
	if isPressingRight:
		direction += 1
	return direction
