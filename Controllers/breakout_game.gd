class_name BreakoutGame extends Node

signal new_round

@export_group("Game Objects")
@export var ball: Ball
@export var arena: Arena
@export var paddles: Node

@export_group("UI")
@export var scores: Node
@export var ui_control: Control
@export var game_end_label: Label
@export var return_to_menu_label: Label
@export var pause_menu: Control

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
var game_end_text = "You broke %s bricks!"
var return_to_menu_text = "[%s] to go back"

var paddle_hits: int = 0
var speed_multiplier: float = 1.0
var current_speed_multiplier: float = speed_multiplier

func _ready() -> void:
	round_timer.timeout.connect(_on_round_timer_ended)
	# ball.bounce_paddle.connect(_on_paddle_hit)

func start() -> void:
	pause_menu.hide()
	arena.set_up()
	reset()

func update() -> void:
	if game_ended and Input.is_action_just_released("return_to_menu"):
		AudioManager.play_audio(select_sfx)
		get_tree().change_scene_to_file("res://Menus/main_menu.tscn")
	
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
	
	update_scores()
	# TODO: Replace this with check for when ball is below arena, then decrement a lives variable
	var is_out_of_bounds: bool = arena.is_below_arena(ball.global_position, ball.get_size())
	if is_out_of_bounds:
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

func update_scores() -> void:
	for child in scores.get_children():
		if child is Control:
			var control_name = child.name
			var label = child.get_child(0)
			if label is Label:
				label.text = str(score[control_name])

func is_game_finished() -> bool:
	# TODO: Logic: If all bricks are destroyed or lives run out, return true
	if arena.is_bricks_empty():
		return true
	return false

func end() -> void:
	AudioManager.play_audio(game_end_tune)
	ui_control.show()
	var return_to_menu_key: String = "Space"
	game_end_label.text = game_end_text % score["Player 1"]# Game end text should include score
	return_to_menu_label.text = return_to_menu_text % return_to_menu_key
	ball.stop()
	ball.hide()
	is_started = false
	game_ended = true

func reset() -> void:
	ui_control.hide()
	ball.show()
	restart_round()
	is_started = true
	game_ended = false
	score = initial_score.duplicate()
	update_scores()

func restart_round() -> void:
	current_speed_multiplier = speed_multiplier
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

# TODO: Reuse this to increase speed when certain number of bricks are destroyed, 
# listen to brick destroyed signal I guess
#func _on_paddle_hit() -> void:
	#paddle_hits += 1
	#if paddle_hits == 10:
		#current_speed_multiplier = 1.5
	#if paddle_hits == 20:
		#current_speed_multiplier = 2.0
