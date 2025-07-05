class_name Breakout extends Node2D

# @onready var game: Game = $Game

@onready var paddle: Paddle = $Paddles/Paddle

@onready var arena: Arena = $Arena

func _ready() -> void:
	arena.set_up()
	# game.start()

func _process(delta: float) -> void:
	paddle.update()
	# game.update()

func _physics_process(delta: float) -> void:
	paddle.physics_update()
	# game.physics_update()
