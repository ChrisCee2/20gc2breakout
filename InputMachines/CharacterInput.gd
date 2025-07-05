class_name CharacterInput extends InputInterface

@export var upKey: String
@export var downKey: String

func update() -> void:
	isPressingUp = Input.is_action_pressed(upKey)
	isPressingDown = Input.is_action_pressed(downKey)
