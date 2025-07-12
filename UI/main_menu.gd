class_name MainMenu extends Control

@onready var play_button: Button = $GridContainer/PlayButton
@onready var exit_button: Button = $GridContainer/ExitButton

var select_sfx: AudioStream = preload("res://Assets/SFX/MainSelectSFX.wav")
var hover_sfx: AudioStream = preload("res://Assets/SFX/MainHoverSFX.wav")

func _ready() -> void:
	play_button.pressed.connect(start_game)
	play_button.mouse_entered.connect(_on_enter)
	
	exit_button.pressed.connect(exit_game)
	exit_button.mouse_entered.connect(_on_enter)

func start_game() -> void:
	AudioManager.play_audio(select_sfx)
	var game_scene = preload("res://Levels/breakout.tscn").instantiate()
	get_tree().root.add_child(game_scene)
	get_tree().current_scene = game_scene
	queue_free()

func exit_game() -> void:
	AudioManager.play_audio(select_sfx)
	# Some hardcoded delay so the audio finished playing
	await get_tree().create_timer(select_sfx.get_length() + 0.1).timeout
	get_tree().quit()

func _on_enter() -> void:
	AudioManager.play_audio(hover_sfx)
