class_name CharacterInput extends InputInterface

@export var leftKey: String
@export var rightKey: String

func update() -> void:
	isPressingLeft = Input.is_action_pressed(leftKey)
	isPressingRight = Input.is_action_pressed(rightKey)
