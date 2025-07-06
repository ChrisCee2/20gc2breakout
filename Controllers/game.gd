class_name Game extends Node

signal new_round

@export var score_to_win: int = 3

@export_group("Game Objects")
@export var ball: Ball
@export var arena: Arena
@export var paddles: Node

@export_group("UI")
@export var scores: Node
@export var ui_control: Control
@export var win_label: Label
@export var return_to_menu_label: Label
@export var pause_menu: Control

@onready var round_timer: Timer = $RoundTimer
var round_start_time: float = 0.5

var select_sfx: AudioStream = preload("res://Assets/SFX/PauseSelectSFX.wav")
var score_sfx: AudioStream = preload("res://Assets/SFX/ScoreSFX.wav")
var win_tune: AudioStream = preload("res://Assets/SFX/WinTune.wav")

var is_started = false
var game_ended = false
var is_paused = false
var round_ended = true
var initial_score: Dictionary = {"Player 1": 0, "Player 2": 0}
var score: Dictionary = initial_score.duplicate()
var win_text = "%s Wins!"
var return_to_menu_text = "[%s] to go back"

var paddle_hits: int = 0
var speed_multiplier: float = 1.0
var current_speed_multiplier: float = speed_multiplier

func _ready() -> void:
	round_timer.timeout.connect(_on_round_timer_ended)
	ball.bounce_paddle.connect(_on_paddle_hit)

func start() -> void:
	pause_menu.hide()
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
	
	var bound: int = arena.isOutOfBoundsX(ball.global_position, ball.getSize())
	if bound == 0:
		return
	if bound == 1:
		score["Player 1"] += 1
	elif bound == -1:
		score["Player 2"] += 1
	update_scores()
	
	var potential_winner: String = get_winner()
	if potential_winner != "":
		end(potential_winner)
	else:
		AudioManager.play_audio(score_sfx)
		var shouldStartLeft: bool = true if bound == -1 else false
		restart_round(shouldStartLeft)

func physics_update() -> void:
	if not is_paused:
		for paddle in paddles.get_children():
			if paddle is Paddle:
				paddle.physics_update()

func update_scores() -> void:
	for child in scores.get_children():
		if child is Control:
			var control_name = child.name
			var label = child.get_child(0)
			if label is Label:
				label.text = str(score[control_name])

func get_winner() -> String:
	for player in score:
		if score[player] >= score_to_win:
			return player
	return ""

func end(winner: String) -> void:
	AudioManager.play_audio(win_tune)
	ui_control.show()
	var return_to_menu_key: String = "Space"
	win_label.text = win_text % winner
	return_to_menu_label.text = return_to_menu_text % return_to_menu_key
	ball.stop()
	ball.hide()
	is_started = false
	game_ended = true

func reset() -> void:
	ui_control.hide()
	ball.show()
	restart_round(randf() < 0.5)
	is_started = true
	game_ended = false
	score = initial_score.duplicate()
	update_scores()

func restart_round(shouldStartLeft: bool) -> void:
	paddle_hits = 0
	current_speed_multiplier = speed_multiplier
	#ball.restart(shouldStartLeft)
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

func _on_paddle_hit() -> void:
	paddle_hits += 1
	if paddle_hits == 10:
		current_speed_multiplier = 1.5
	if paddle_hits == 20:
		current_speed_multiplier = 2.0
