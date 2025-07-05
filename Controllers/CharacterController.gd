class_name CharacterController extends Node

@export var input: InputInterface
@export var object: StaticBody2D
@export var velocity = 1

func update(
	speed_multiplier: float,
	distance_from_left_bound: float, 
	distance_from_right_bound: float):
	if not input:
		return
	var x: int = input.getDirection()
	if x < 0:
		x *= min(velocity, distance_from_left_bound)
	elif x > 0:
		x *= min(velocity, distance_from_right_bound)
		
	object.global_position += Vector2(x * speed_multiplier, 0)
