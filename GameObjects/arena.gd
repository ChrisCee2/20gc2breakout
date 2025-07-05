class_name Arena extends Node2D

@onready var wall_1 = $Wall
@onready var wall_2 = $Wall1

@onready var wall_1_sprite = $Wall/Sprite2D
@onready var wall_2_sprite = $Wall1/Sprite2D

@onready var divider = $Divider

@export var arena_range_in_pixels = Vector2(170, 90)
@export var divider_width = 1

func _ready() -> void:
	wall_1.global_position = global_position - (Vector2.DOWN * arena_range_in_pixels.y / 2)
	wall_2.global_position = global_position + (Vector2.DOWN * arena_range_in_pixels.y / 2)
	divider.scale = Vector2(divider_width, arena_range_in_pixels.y)

func getUpperBound() -> float:
	return wall_1.global_position.y + (wall_1_sprite.scale.y / 2)

func getLowerBound() -> float:
	return wall_2.global_position.y - (wall_2_sprite.scale.y / 2)

func getLeftBound() -> float:
	return global_position.x - (arena_range_in_pixels.x / 2)

func getRightBound() -> float:
	return global_position.x + (arena_range_in_pixels.x / 2)

# Returns which horizontal bounds an object as past with -1 (left) or 1 (right) or 0 (none)
func isOutOfBoundsX(position: Vector2, size: Vector2) -> int:
	if position.x + (size.x / 2) < getLeftBound():
		return -1
	elif position.x - (size.x / 2) > getRightBound():
		return 1
	return 0
