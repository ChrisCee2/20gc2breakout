class_name Pong extends Node2D

@onready var game: Game = $Game
@onready var second_paddle: Paddle = $Paddles/Paddle1
@onready var computer_input: ComputerInput = $Paddles/Paddle1/ComputerInput
@export var is_single_player: bool = false

func _ready() -> void:
	if is_single_player:
		second_paddle.set_input(computer_input)
	game.start()

func _process(delta: float) -> void:
	game.update()

func _physics_process(delta: float) -> void:
	game.physics_update()
