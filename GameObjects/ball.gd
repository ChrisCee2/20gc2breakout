class_name Ball extends RigidBody2D

signal bounce
signal bounce_paddle
signal bounce_brick

@export var speed: float = 60.0
@export var start_position: Vector2 = Vector2(0, 0)
@export var start_direction: Vector2 = Vector2.UP
@export_range(1, 89) var max_start_angle: float = 60

@onready var sprite: Sprite2D = $Sprite2D

var current_speed_multiplier: float = 1

var bounce_sfx = preload("res://Assets/SFX/BounceSFX.wav")
var paddle_bounce_sfx = preload("res://Assets/SFX/PaddleBounceSFX.wav")

func _ready() -> void:
	body_entered.connect(handle_collision)

func start() -> void:
	freeze = false

func stop() -> void:
	var velocity: Vector2 = linear_velocity
	freeze = true
	linear_velocity = velocity

func restart() -> void:
	global_position = start_position
	var angle = start_direction.angle() + deg_to_rad(randf_range(-max_start_angle, max_start_angle))
	var x = cos(angle)
	var y = sin(angle)
	linear_velocity = speed * Vector2(x, y).normalized()
	start()

func get_size() -> Vector2:
	return sprite.scale

func handle_collision(collision: Node) -> void:
	var direction = linear_velocity.normalized()
	if collision is Paddle:
		AudioManager.play_audio(paddle_bounce_sfx)
		bounce_paddle.emit()
		direction = collision.get_bounce_direction(global_position)
	else:
		AudioManager.play_audio(bounce_sfx)
		bounce.emit()
		if collision is Brick:
			emit_signal("bounce_brick")
			collision.queue_free()
	linear_velocity = direction * speed * current_speed_multiplier
