class_name ComputerInput extends InputInterface

@export var game: Game
@export var arena: Arena
@export var ball: Ball
@export var paddle: Paddle

@onready var reaction_timer: Timer = $ReactionTimer
@onready var input_timer: Timer = $InputTimer

var rtc_range: Array = [2, 10]
var should_set_hit_position: bool = false
var desired_hit_position: float = 0 # Where on paddle to hit the ball
var should_set_rtc_error: bool = false
var return_to_center_error: float = 0
var min_move_amount: float = 4 # Minimum amount of pixels needed before moving paddle
var should_move: bool = false
var reacted: bool = false

var reaction_speed = 0.26 # Reaction speed in seconds
var reaction_timer_ended: bool = true

var min_delay_between_inputs: float = 0.3 # Time between inputs in seconds
var current_delay_between_inputs: float = min_delay_between_inputs
var max_delay_between_inputs: float = 1.0
var delay_increment: float = 0.05
var input_timer_ended: bool = true

var min_ball_error: float = 1
var max_ball_error: float = 6
var current_ball_error: float = min_ball_error
var ball_error_increment: float = 0.5

var ball_error: float = 0 # How many pixels it is ok for the paddle to be from the ball

func _ready() -> void:
	input_timer.timeout.connect(_input_timer_ended)
	reaction_timer.timeout.connect(_reaction_timer_ended)
	ball.bounce.connect(reset_reaction_timer)
	ball.bounce_paddle.connect(reset_reaction_timer)
	game.new_round.connect(reset)

func update() -> void:
	if not reaction_timer_ended or not input_timer_ended:
		return
	
	if is_ball_coming() and should_set_hit_position:
		var hit_range: Array = get_hit_range()
		desired_hit_position = randf_range(hit_range[0], hit_range[1])
		should_set_hit_position = false
	
	if not is_ball_coming() and should_set_rtc_error:
		return_to_center_error = randf_range(rtc_range[0], rtc_range[1])
		should_set_rtc_error = false
	
	var target = ball.global_position.y + desired_hit_position
	var distance_from_target: float = paddle.global_position.y - target
	
	if (abs(distance_from_target) >= min_move_amount):
		should_move = true
	
	# If ball is not coming, return to center
	if not is_ball_coming():
		should_set_hit_position = true
		distance_from_target = paddle.global_position.y - arena.global_position.y
	
	if is_ball_coming():
		should_set_rtc_error = true
	
	if should_move:
		set_direction_to_target(distance_from_target)

func set_direction_to_target(distance_from_target: int) -> void:
	var error = get_ball_error() if is_ball_coming() else return_to_center_error
	if abs(distance_from_target) <= error:
		isPressingUp = false
		isPressingDown = false
		should_move = false
		should_set_hit_position = true
		reset_input_timer()
	elif distance_from_target < 0 :
		isPressingUp = false
		isPressingDown = true
	else:
		isPressingUp = true
		isPressingDown = false

func get_hit_range() -> Array[float]:
	var paddle_height = paddle.getSize().y
	return [paddle_height/2, -paddle_height/2]

func is_ball_coming() -> bool:
	# Find side of paddle
	var is_left = true if arena.global_position.x - paddle.global_position.x >= 0 else false
	return (is_left and ball.velocity.x <= 0) or (not is_left and ball.velocity.x > 0)

func reset_input_timer() -> void:
	input_timer_ended = false
	input_timer.stop()
	input_timer.start(randf_range(min_delay_between_inputs, current_delay_between_inputs))

func reset_reaction_timer() -> void:
	reaction_timer_ended = false
	reaction_timer.stop()
	reaction_timer.start(reaction_speed)

func _input_timer_ended() -> void:
	input_timer_ended = true

func _reaction_timer_ended() -> void:
	reaction_timer_ended = true

func get_ball_error() -> float:
	return randf_range(min_ball_error, current_ball_error)

func reset() -> void:
	current_ball_error = min_ball_error
	current_delay_between_inputs = min_delay_between_inputs

func _bounce_paddle() -> void:
	reset_reaction_timer()
	current_ball_error = min(current_ball_error + ball_error_increment, max_ball_error)
	current_delay_between_inputs = min(
		current_delay_between_inputs + delay_increment, 
		max_delay_between_inputs
	)
