class_name Ball extends StaticBody2D

signal bounce
signal bounce_paddle
signal bounce_brick

@export var paddles: Node
@export var game: BreakoutGame
@export var arena: Arena
@export var start_speed: float = 1.0
@export var start_position: Vector2 = Vector2(0, 0)
@export var start_direction: Vector2 = Vector2.UP
@export_range(1, 89) var max_start_angle: float = 60

@onready var sprite: Sprite2D = $Sprite2D
@onready var shape_cast: ShapeCast2D = $ShapeCast2D

var bounce_sfx = preload("res://Assets/SFX/BounceSFX.wav")
var paddle_bounce_sfx = preload("res://Assets/SFX/PaddleBounceSFX.wav")

var is_active: bool = false
var current_speed: float = start_speed
var velocity: Vector2 = Vector2.ZERO
var current_collisions: Array[StaticBody2D] =[]

var normal_angle_moe: float = 0.01

func start():
	is_active = true

func stop():
	is_active = false

func restart() -> void:
	current_speed = start_speed
	current_collisions = []
	global_position = start_position
	var angle = start_direction.angle() + deg_to_rad(randf_range(-max_start_angle, max_start_angle))
	var x = cos(angle)
	var y = sin(angle)
	velocity = start_speed * Vector2(x, y).normalized()
	start()

func _physics_process(delta: float) -> void:
	physics_update(get_distance_from_lower_bound(), get_distance_from_upper_bound())

func physics_update(distance_from_lower_bound: float, distance_from_upper_bound: float) -> void:
	if not is_active:
		return
	
	var collision_count = shape_cast.get_collision_count()
	handle_collisions(collision_count)
	update_current_collisions(shape_cast.get_collision_count())
	
	global_position += velocity * game.current_speed_multiplier

func get_size() -> Vector2:
	return sprite.scale

func handle_paddle_bounce(paddle: Paddle, collision_normal: Vector2) -> void:
	AudioManager.play_audio(paddle_bounce_sfx)
	bounce_paddle.emit()
	if collision_normal.snappedf(normal_angle_moe) != \
	Vector2.UP.rotated(paddle.rotation).snappedf(normal_angle_moe):
		velocity = velocity.bounce(collision_normal)
	else:
		velocity = paddle.get_bounce_direction(global_position) * start_speed;

func handle_bounce(collision_normal: Vector2) -> void:
	bounce.emit()
	AudioManager.play_audio(bounce_sfx)
	velocity = velocity.bounce(collision_normal)

func get_distance_from_upper_bound() -> float:
	if not arena:
		return 10000
	var paddle_size: Vector2 = get_size()
	return (global_position.y - (paddle_size.y / 2)) - arena.get_upper_bound()

func get_distance_from_lower_bound() -> float:
	if not arena:
		return 10000
	var paddle_size: Vector2 = get_size()
	return arena.get_lower_bound() - (global_position.y + (paddle_size.y / 2))

func update_current_collisions(collision_count: int) -> void:
	current_collisions = []
	for i in range(collision_count):
		current_collisions.append(shape_cast.get_collider(i))

func handle_collisions(collision_count: int) -> void:
	for i in range(collision_count):
		var collision = shape_cast.get_collider(i)
		if collision not in current_collisions:
			var collision_normal: Vector2 = shape_cast.get_collision_normal(0)
			if collision is Paddle:
				handle_paddle_bounce(collision, collision_normal)
			else:
				handle_bounce(collision_normal)
			if collision is Brick:
				emit_signal("bounce_brick")
				collision.queue_free()
