class_name BreakoutGame extends Node

signal new_round

@export_group("Game Objects")
@export var ball: Ball
@export var arena: Arena
@export var paddles: Node

@export_group("UI")
@export var game_end_text: GameEndText
@export var pause_menu: Control
@export var player_info: PlayerInfo
@export var player_info_offset: Vector2 = Vector2(0, 40)

@onready var round_timer: Timer = $RoundTimer
var round_start_time: float = 0.5

var select_sfx: AudioStream = preload("res://Assets/SFX/PauseSelectSFX.wav")
var score_sfx: AudioStream = preload("res://Assets/SFX/ScoreSFX.wav")
var game_end_tune: AudioStream = preload("res://Assets/SFX/GameEndTune.wav")

var is_started = false
var game_ended = false
var is_paused = false
var round_ended = true
var initial_score: Dictionary = {"Player 1": 0, "Player 2": 0}
var score: Dictionary = initial_score.duplicate()
var score_text = "You broke %s bricks!"
var return_to_menu_text = "[%s] to go back"

var paddle_hits: int = 0
var speed_multiplier: float = 1.0
var current_speed_multiplier: float = speed_multiplier
var speed_increment: float = 0.02

@export_group("Game Settings")
@export var lives: int = 3
var current_lives: int = 0

var score_file_path: String = "user://high_score.dat"
var high_score: int = 0
var high_score_text: String = "High score! "

func _ready() -> void:
	round_timer.timeout.connect(_on_round_timer_ended)
	player_info.global_position += player_info_offset
	ball.bounce.connect(_on_bounce)
	ball.bounce_paddle.connect(_on_bounce)
	ball.bounce_brick.connect(_on_brick_break)

func start() -> void:
	load_score()
	current_lives = lives
	update_lives_label()
	pause_menu.hide()
	arena.set_up()
	for paddle in paddles.get_children():
		if paddle is Paddle:
			paddle.initialize(
				Vector2(arena.global_position.x, arena.get_lower_bound()) + (Vector2.UP * 10)
			)
	reset()

func update() -> void:
	if game_ended and Input.is_action_just_released("return_to_menu"):
		AudioManager.play_audio(select_sfx)
		get_tree().change_scene_to_file("res://UI/main_menu.tscn")
	
	if not game_ended and Input.is_action_just_pressed("pause"):
		pause() if not is_paused else resume()
	
	if not is_paused:
		for paddle in paddles.get_children():
			if paddle is Paddle:
				paddle.update()
	
	if not is_started:
		return
	
	if is_game_finished():
		end()
	
	update_score()
	var is_out_of_bounds: bool = arena.is_below_arena(ball.global_position, ball.get_size())
	if is_out_of_bounds:
		current_lives -= 1
		update_lives_label()
		if is_game_finished():
			end()
		else:
			AudioManager.play_audio(score_sfx)
			restart_round()

func physics_update() -> void:
	if not is_paused:
		for paddle in paddles.get_children():
			if paddle is Paddle:
				paddle.physics_update(arena.get_left_bound(), arena.get_right_bound())

func update_score() -> void:
	player_info.score_label.text = str(score["Player 1"])

func is_game_finished() -> bool:
	if arena.is_bricks_empty() or current_lives == 0:
		return true
	return false

func end() -> void:
	AudioManager.play_audio(game_end_tune)
	game_end_text.show()
	var win_text: String = score_text % score["Player 1"]
	if score["Player 1"] > high_score:
		save_score()
		win_text = high_score_text + win_text
	var return_to_menu_key: String = "Space"
	game_end_text.game_end_label.text = win_text
	game_end_text.return_to_menu_label.text = return_to_menu_text % return_to_menu_key
	ball.stop()
	ball.hide()
	is_started = false
	game_ended = true

func reset() -> void:
	game_end_text.hide()
	ball.show()
	restart_round()
	is_started = true
	game_ended = false
	score = initial_score.duplicate()
	update_score()

func restart_round() -> void:
	current_speed_multiplier = speed_multiplier
	ball.current_speed_multiplier = current_speed_multiplier
	for paddle in paddles.get_children():
		if paddle is Paddle:
			paddle.current_speed_multiplier = current_speed_multiplier
	ball.restart()
	ball.stop()
	round_timer.start(round_start_time)
	new_round.emit()

func start_round() -> void:
	ball.start()

func pause() -> void:
	AudioManager.play_audio(select_sfx)
	is_paused = true
	pause_menu.show()
	round_timer.paused = true
	# Resume player controls
	if not game_ended:
		ball.stop()

func resume() -> void:
	AudioManager.play_audio(select_sfx)
	is_paused = false
	pause_menu.hide()
	round_timer.paused = false
	# Resume player controls
	if not game_ended and round_timer.time_left == 0:
		ball.start()

func _on_round_timer_ended() -> void:
	round_timer.stop()
	if not is_paused:
		ball.start()

func update_lives_label() -> void:
	player_info.lives_label.text = str(current_lives)

func _on_bounce() -> void:
	current_speed_multiplier = speed_multiplier + (speed_increment * score["Player 1"])
	ball.current_speed_multiplier = current_speed_multiplier
	for paddle in paddles.get_children():
		if paddle is Paddle:
			paddle.current_speed_multiplier = current_speed_multiplier

func _on_brick_break() -> void:
	score["Player 1"] += 1
	
	var paddle_width_percentage: float = 1 - (.5 * (score["Player 1"] / arena.brick_count))
	for paddle in paddles.get_children():
		if paddle is Paddle:
			var paddle_size: Vector2 = paddle.start_size
			paddle.update_size(Vector2(paddle_size.x * paddle_width_percentage, paddle_size.y))
	_on_bounce()

func save_score() -> void:
	var save_file = FileAccess.open(score_file_path, FileAccess.WRITE)
	var score_map = {"score": score["Player 1"]}
	save_file.store_line(JSON.stringify(score_map))

func load_score() -> void:
	if not FileAccess.file_exists(score_file_path):
		return
	
	var json = JSON.new()
	var save_file = FileAccess.open(score_file_path, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var result = json.parse(json_string)
		if not result == OK:
			return
		
		var data = json.data
		high_score = data["score"]
		player_info.high_score_label.text = str(high_score)
