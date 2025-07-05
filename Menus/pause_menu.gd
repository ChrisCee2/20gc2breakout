class_name PauseMenu extends Control

@export var game: Game

@onready var resume_button: Button = $GridContainer/ResumeButton
@onready var back_button: Button = $GridContainer/BackButton

var select_sfx: AudioStream = preload("res://Assets/SFX/PauseSelectSFX.wav")
var hover_sfx: AudioStream = preload("res://Assets/SFX/PauseHoverSFX.wav")

func _ready() -> void:
	hide()
	resume_button.pressed.connect(resume_game)
	back_button.pressed.connect(return_to_main_menu)
	resume_button.mouse_entered.connect(_on_enter)
	back_button.mouse_entered.connect(_on_enter)

func return_to_main_menu() -> void:
	AudioManager.play_audio(select_sfx)
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")

func resume_game() -> void:
	game.resume()

func _on_enter() -> void:
	AudioManager.play_audio(hover_sfx)
