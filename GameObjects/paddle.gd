class_name Paddle extends StaticBody2D

@export var facing_direction: Vector2 = Vector2(0,0)
@export var characterInput: InputInterface
@export var game: Game
@export var arena: Arena
@export_range(1, 89) var maxBounceAngle: float = 60
@onready var controller = $CharacterController

@onready var sprite = $Sprite2D

func set_input(input_interface: InputInterface) -> void:
	controller.input = input_interface

func _ready() -> void:
	if characterInput:
		controller.input = characterInput

func update():
	if controller and arena:
		if controller.input != null:
			controller.input.update()

func physics_update() -> void:
	if controller:
		controller.update(
			game.current_speed_multiplier,
			getDistanceFromLowerBound(), 
			getDistanceFromUpperBound())

func getSize() -> Vector2:
	return sprite.scale

func getDistanceFromUpperBound() -> float:
	var paddleSize: Vector2 = getSize()
	return (global_position.y - (paddleSize.y / 2)) - arena.getUpperBound()

func getDistanceFromLowerBound() -> float:
	var paddleSize: Vector2 = getSize()
	return arena.getLowerBound() - (global_position.y + (paddleSize.y / 2))

func getBounceAngle(bouncePosition: Vector2) -> float:
	var distanceFromCenter = global_position - bouncePosition
	if distanceFromCenter.y == 0:
		return 0
	# Flipping sign because negative y is up
	return -(maxBounceAngle * (distanceFromCenter.y / (getSize().y / 2)))

func get_bounce_angle_range() -> Array:
	return [
		facing_direction.angle() - deg_to_rad(maxBounceAngle), 
		facing_direction.angle() + deg_to_rad(maxBounceAngle),
	]

func get_bounce_direction(bouncePosition: Vector2) -> Vector2:
	var percent_from_bottom = ((global_position.y + (getSize().y / 2)) - bouncePosition.y) / getSize().y
	var bounce_angle_range = get_bounce_angle_range()
	# Reversing logic only works for paddles that directly face left or right
	# Reversing because y decreases upwards, so when its rotated by 70 degrees it rotates downwards. It should be the opposite
	if (rad_to_deg(facing_direction.angle()) < 90):
		bounce_angle_range.reverse()
	var angle: float = bounce_angle_range[0] + (bounce_angle_range[1] - bounce_angle_range[0]) * percent_from_bottom
	
	return Vector2(cos(angle), sin(angle))
