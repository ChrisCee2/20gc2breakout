class_name CharacterController extends Node

@export var input: InputInterface
@export var object: StaticBody2D
@export var velocity = 1

func update(
	speed_multiplier: float,
	distance_from_lower_bound: float, 
	distance_from_upper_bound: float):
	if not input:
		return
	var y: int = input.getDirection()
	if y < 0:
		y *= min(velocity, distance_from_upper_bound)
	elif y > 0:
		y *= min(velocity, distance_from_lower_bound)
		
	object.global_position += Vector2(0, y * speed_multiplier)
