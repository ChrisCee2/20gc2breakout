class_name Ball extends StaticBody2D

signal bounce_wall
signal bounce_paddle

@export var paddles: Node
# @export var game: Game
@export var arena: Arena
@export var start_speed: float = 1.0
@export_range(1, 89) var max_start_angle: float = 60

@onready var sprite: Sprite2D = $Sprite2D
@onready var shape_cast: ShapeCast2D = $ShapeCast2D

var hit_wall_sfx = preload("res://Assets/SFX/HitWallSFX.wav")
var hit_paddle_sfx = preload("res://Assets/SFX/HitPaddleSFX.wav")

var is_active: bool = false
var current_speed: float = start_speed
var velocity: Vector2 = Vector2.ZERO
var current_paddle_collision: Paddle = null

func _ready() -> void:
	restart()

func start():
	is_active = true

func stop():
	is_active = false

func restart() -> void:
	current_speed = start_speed
	current_paddle_collision = null
	var start_position: Vector2 = Vector2.ZERO
	if arena:
		start_position = arena.global_position
	global_position = start_position
	var angle = deg_to_rad(-randf_range(1, max_start_angle))
	var x = cos(angle)
	var y = sin(angle)
	velocity = start_speed * Vector2(x, y).normalized()
	start()

func _physics_process(delta: float) -> void:
	physics_update(getDistanceFromLowerBound(), getDistanceFromUpperBound())

func physics_update(distance_from_lower_bound: float, distance_from_upper_bound: float) -> void:
	if not is_active:
		return
	
	var collision = shape_cast.get_collider(0)
	if collision:
		if collision is Paddle:
			if not current_paddle_collision:
				handle_paddle_bounce(collision)
		else:
			handle_bounce(0)
	elif current_paddle_collision:
		current_paddle_collision = null
	var curr_velocity = velocity
	
	# If approaching wall and velocity would make it pass wall, make it not
	if velocity.y < 0 and distance_from_upper_bound < curr_velocity.y:
		curr_velocity = scaleVelocityForWallBounce(curr_velocity, distance_from_upper_bound)
	elif velocity.y > 0 and velocity.y < 0 and distance_from_lower_bound < curr_velocity.y:
		curr_velocity = scaleVelocityForWallBounce(curr_velocity, distance_from_lower_bound)
	global_position += curr_velocity #* game.current_speed_multiplier

func getBounceVelocity() -> Vector2:
	return Vector2.ZERO

func get_size() -> Vector2:
	return sprite.scale

func isBallOverlappingPaddle(paddle: Paddle) -> bool:
	return paddle.global_position.x + (paddle.get_size().x / 2) >= global_position.x - (get_size().x / 2) && \
	paddle.global_position.x - (paddle.get_size().x / 2) <= global_position.x + (get_size().x / 2) && \
	paddle.global_position.y + (paddle.get_size().y / 2) >= global_position.y - (get_size().y / 2) && \
	paddle.global_position.y - (paddle.get_size().y / 2) <= global_position.y + (get_size().y / 2)

func handle_paddle_bounce(paddle: Paddle) -> void:
	AudioManager.play_audio(hit_paddle_sfx)
	bounce_paddle.emit()
	velocity = paddle.get_bounce_direction(global_position) * start_speed;
	current_paddle_collision = paddle

func handle_wall_bounce(
	distance_from_lower_bound: float, 
	distance_from_upper_bound: float) -> void:
	if distance_from_lower_bound <= 0 || distance_from_upper_bound <= 0:
		bounce_wall.emit()
		AudioManager.play_audio(hit_wall_sfx)
		velocity *= Vector2(1.0, -1.0)
		velocity = velocity.normalized() * current_speed

func handle_bounce(collision_index: int) -> void:
	var normal = shape_cast.get_collision_normal(collision_index)
	velocity = velocity.bounce(normal)

func scaleVelocityForWallBounce(current_velocity: Vector2, y: float) -> Vector2:
	bounce_wall.emit()
	AudioManager.play_audio(hit_wall_sfx)
	var factor = abs(current_velocity.y) / y
	current_velocity /= factor
	current_velocity.y = -y
	return current_velocity

func getDistanceFromUpperBound() -> float:
	if not arena:
		return 10000
	var paddleSize: Vector2 = get_size()
	return (global_position.y - (paddleSize.y / 2)) - arena.get_upper_bound()

func getDistanceFromLowerBound() -> float:
	if not arena:
		return 10000
	var paddleSize: Vector2 = get_size()
	return arena.get_lower_bound() - (global_position.y + (paddleSize.y / 2))
