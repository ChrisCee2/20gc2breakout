class_name Breakout extends Node2D

# @onready var game: Game = $Game

@onready var paddle: Paddle = $Paddles/Paddle

func _ready() -> void: return
	# game.start()

func _process(delta: float) -> void:
	paddle.update()
	# game.update()

func _physics_process(delta: float) -> void:
	paddle.physics_update()
	# game.physics_update()
