class_name Brick extends StaticBody2D

@onready var sprite: Sprite2D = $Sprite2D

func set_color(color: Color) -> void:
	modulate = color
