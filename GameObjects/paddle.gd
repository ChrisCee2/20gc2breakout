class_name Paddle extends StaticBody2D

@export var characterInput: InputInterface
@export var game: BreakoutGame
@export_range(1, 89) var maxBounceAngle: float = 60
@onready var controller = $CharacterController

@onready var sprite = $Sprite2D

func set_input(input_interface: InputInterface) -> void:
	controller.input = input_interface

func initialize(start_position: Vector2 = Vector2.ZERO) -> void:
	global_position = start_position
	if characterInput:
		controller.input = characterInput

func update():
	if controller.input != null:
		controller.input.update()

func physics_update(arena_left_bound: float = -1000, arena_right_bound: float = 1000) -> void:
	if controller:
		controller.update(
			game.current_speed_multiplier,
			get_distance_from_left_bound(arena_left_bound), 
			get_distance_from_right_bound(arena_right_bound))

func get_size() -> Vector2:
	return sprite.scale

func get_distance_from_left_bound(left_bound: float) -> float:
	return (global_position.x - (get_size().x / 2)) - left_bound

func get_distance_from_right_bound(right_bound: float) -> float:
	return right_bound - (global_position.x + (get_size().x / 2))

# Gets signed distance of a position from the center of a paddle relative to the facing direction of the paddle
func get_distance_from_center(ball_position: Vector2) -> float:
	var vector_along_paddle = -Vector2.UP.rotated(rotation).orthogonal()
	var position_on_paddle = ball_position.project(vector_along_paddle)
	return (position_on_paddle - global_position).dot(vector_along_paddle)

func get_bounce_angle_range() -> Array:
	return [
		Vector2.UP.rotated(rotation).angle() - deg_to_rad(maxBounceAngle), 
		Vector2.UP.rotated(rotation).angle() + deg_to_rad(maxBounceAngle),
	]

func get_bounce_direction(ball_position: Vector2) -> Vector2:
	var distance_from_edge = get_distance_from_center(ball_position) + (get_size().x / 2)
	var percent_from_bottom = distance_from_edge / get_size().x
	var angle_range = get_bounce_angle_range()
	var angle: float = angle_range[0] + (angle_range[1] - angle_range[0]) * percent_from_bottom
	return Vector2(cos(angle), sin(angle))
