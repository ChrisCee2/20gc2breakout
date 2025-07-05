class_name Arena extends Node2D

@onready var wall_1 = $Wall
@onready var wall_2 = $Wall1
@onready var ceiling = $Ceiling

@onready var wall_1_sprite = $Wall/Sprite2D
@onready var wall_2_sprite = $Wall1/Sprite2D
@onready var ceiling_sprite = $Ceiling/Sprite2D

@export var wall_thickness: float = 4 # In pixels
@export var arena_range = Vector2(140, 140) # In pixels

func set_up() -> void:
	wall_1.global_position = global_position + \
	(Vector2.LEFT * arena_range.x / 2) + \
	(Vector2.LEFT * wall_thickness / 2)
	wall_2.global_position = global_position + \
	(Vector2.RIGHT * arena_range.x / 2) + \
	(Vector2.RIGHT * wall_thickness / 2)
	ceiling.global_position = global_position + \
	(Vector2.UP * arena_range.y / 2) + \
	(Vector2.UP * wall_thickness / 2)
	
	set_wall_size(wall_1, wall_thickness, arena_range.y)
	set_wall_size(wall_2, wall_thickness, arena_range.y)
	set_wall_size(ceiling, arena_range.x + (wall_thickness * 2), wall_thickness)

func set_wall_size(wall:StaticBody2D, x: float, y: float) -> void:
	var collision_shape: CollisionShape2D = wall.find_child("CollisionShape2D", false)
	var sprite: Sprite2D = wall.find_child("Sprite2D", false)
	if not sprite or not collision_shape:
		return
	collision_shape.shape.set_size(Vector2(x, y))
	sprite.scale = Vector2(x, y)

func get_upper_bound() -> float:
	return global_position.y - (arena_range.y / 2)

func get_lower_bound() -> float:
	return global_position.y + (arena_range.y / 2)

func get_left_bound() -> float:
	return wall_1.global_position.x + (wall_1_sprite.scale.x / 2)

func get_right_bound() -> float:
	return wall_2.global_position.x - (wall_2_sprite.scale.x / 2)

func is_below_arena(position: Vector2, size: Vector2) -> bool:
	return position.y + (size.x / 2) > get_lower_bound()
