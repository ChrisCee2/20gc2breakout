class_name Arena extends Node2D

@onready var wall_1: StaticBody2D = $Wall
@onready var wall_2: StaticBody2D= $Wall1
@onready var ceiling: StaticBody2D = $Ceiling
@onready var bricks: Node = $Bricks

@onready var wall_1_sprite: Sprite2D = $Wall/Sprite2D
@onready var wall_2_sprite: Sprite2D = $Wall1/Sprite2D
@onready var ceiling_sprite: Sprite2D = $Ceiling/Sprite2D

@export var wall_thickness: float = 4 # In pixels
@export var arena_range = Vector2(140, 140) # In pixels

@export var brick_count: float = 16
var brick_width: float = 16
var brick_height: float = 8
var brick_padding: float = 1
var brick_scene = preload("res://GameObjects/brick.tscn")
var centered_offset: Vector2 = Vector2(8, 2)

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
	
	for brick in bricks.get_children():
		bricks.remove_child(brick)
		brick.queue_free()
	set_up_bricks()

# This assumes all bricks are the same size
func set_up_bricks() -> void:
	var row: int = 0
	var col: int = 0
	var left_bound: float = get_left_bound()
	var right_bound: float = get_right_bound()
	var upper_bound: float = get_upper_bound()
	var max_col: int = floor((right_bound - left_bound) / (brick_padding + brick_width))
	var arena_padding: float = ((right_bound - left_bound) - \
	((max_col * (brick_padding + brick_width)) - brick_width)) / 2
	for i in range(brick_count):
		var new_brick: Brick = brick_scene.instantiate()
		bricks.add_child(new_brick)
		if left_bound + (col * (brick_padding + brick_width)) + arena_padding + brick_width > right_bound:
			row += 1
			col = 0
		var x: float = left_bound + (col * (brick_padding + brick_width)) + arena_padding
		var y: float = upper_bound + (row * (brick_padding + brick_height)) + arena_padding
		new_brick.global_position = Vector2(x, y) + centered_offset
		col += 1

func set_wall_size(wall:StaticBody2D, x: float, y: float) -> void:
	var collision_shape: CollisionShape2D = wall.find_child("CollisionShape2D", false)
	var sprite: Sprite2D = wall.find_child("Sprite2D", false)
	if not sprite or not collision_shape:
		return
	collision_shape.shape.set_size(Vector2(x, y))
	sprite.scale = Vector2(x, y)

func get_upper_bound() -> float:
	return global_position.y - (arena_range.y / 2) + (ceiling_sprite.scale.y / 2)

func get_lower_bound() -> float:
	return global_position.y + (arena_range.y / 2)

func get_left_bound() -> float:
	return wall_1.global_position.x + (wall_1_sprite.scale.x / 2)

func get_right_bound() -> float:
	return wall_2.global_position.x - (wall_2_sprite.scale.x / 2)

func is_below_arena(position: Vector2, size: Vector2) -> bool:
	return position.y + (size.x / 2) > get_lower_bound()
