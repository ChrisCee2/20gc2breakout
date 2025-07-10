class_name Breakout extends Node2D

# @onready var game: Game = $Game

@onready var game: BreakoutGame = $BreakoutGame

func _ready() -> void:
	game.start()

func _process(delta: float) -> void:
	game.update()
