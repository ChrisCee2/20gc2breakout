class_name Ball extends StaticBody2D

signal bounce_wall
signal bounce_paddle

@export var paddles: Node
@export var game: Game
@export var arena: Arena
@export var start_speed: float = 1.0

@onready var sprite: Sprite2D = $Sprite2D

var hit_wall_sfx = preload("res://Assets/SFX/HitWallSFX.wav")
var hit_paddle_sfx = preload("res://Assets/SFX/HitPaddleSFX.wav")

var is_active: bool = false
var current_speed: float = start_speed
var velocity: Vector2 = Vector2.ZERO
var paddlesBeingCollidedWith: Array[Paddle] = []

func start():
	is_active = true

func stop():
	is_active = false

func restart(shouldStartLeft: bool) -> void:
	paddlesBeingCollidedWith = []
	var start_position: Vector2 = Vector2.ZERO
	if arena:
		start_position = arena.global_position
	global_position = start_position
	var angle = deg_to_rad(randf_range(20, 60))
	var x = cos(angle) * (-1 if shouldStartLeft else 1)
	var y = sin(angle) * (-1 if randf() < 0.5 else 1)
	velocity = start_speed * Vector2(x, y).normalized()
	start()
	current_speed = start_speed

func _ready() -> void:
	restart(randf() < 0.5)

func _physics_process(delta: float) -> void:
	physics_update(getDistanceFromLowerBound(), getDistanceFromUpperBound())

func physics_update(distance_from_lower_bound: float, distance_from_upper_bound: float) -> void:
	if not is_active:
		return
	
	handlePaddleBounce()
	handleWallBounce(distance_from_lower_bound, distance_from_upper_bound)
	var curr_velocity = velocity
	
	# If approaching wall and velocity would make it pass wall, make it not
	if velocity.y < 0 and distance_from_upper_bound < curr_velocity.y:
		curr_velocity = scaleVelocityForWallBounce(curr_velocity, distance_from_upper_bound)
	elif velocity.y > 0 and velocity.y < 0 and distance_from_lower_bound < curr_velocity.y:
		curr_velocity = scaleVelocityForWallBounce(curr_velocity, distance_from_lower_bound)
	global_position += curr_velocity * game.current_speed_multiplier

func getBounceVelocity() -> Vector2:
	return Vector2.ZERO

func getSize() -> Vector2:
	return sprite.scale

func isBallOverlappingPaddle(paddle: Paddle) -> bool:
	return paddle.global_position.x + (paddle.getSize().x / 2) >= global_position.x - (getSize().x / 2) && \
	paddle.global_position.x - (paddle.getSize().x / 2) <= global_position.x + (getSize().x / 2) && \
	paddle.global_position.y + (paddle.getSize().y / 2) >= global_position.y - (getSize().y / 2) && \
	paddle.global_position.y - (paddle.getSize().y / 2) <= global_position.y + (getSize().y / 2)

func handlePaddleBounce() -> void:
	var collidingPaddles: Array[Paddle] = []
	for paddle in paddles.get_children():
		if paddle is Paddle and isBallOverlappingPaddle(paddle):
			collidingPaddles.append(paddle)
			if paddle not in paddlesBeingCollidedWith:
				AudioManager.play_audio(hit_paddle_sfx)
				bounce_paddle.emit()
				var direction_x = 1 if velocity.x < 0 else -1
				var angle = deg_to_rad(paddle.getBounceAngle(global_position))
				var x = cos(angle)
				var y = sin(angle)
				velocity = paddle.get_bounce_direction(global_position) * start_speed;
	paddlesBeingCollidedWith = collidingPaddles

func handleWallBounce(
	distance_from_lower_bound: float, 
	distance_from_upper_bound: float) -> void:
	if distance_from_lower_bound <= 0 || distance_from_upper_bound <= 0:
		bounce_wall.emit()
		AudioManager.play_audio(hit_wall_sfx)
		velocity *= Vector2(1.0, -1.0)
		velocity = velocity.normalized() * current_speed

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
	var paddleSize: Vector2 = getSize()
	return (global_position.y - (paddleSize.y / 2)) - arena.getUpperBound()

func getDistanceFromLowerBound() -> float:
	if not arena:
		return 10000
	var paddleSize: Vector2 = getSize()
	return arena.getLowerBound() - (global_position.y + (paddleSize.y / 2))
