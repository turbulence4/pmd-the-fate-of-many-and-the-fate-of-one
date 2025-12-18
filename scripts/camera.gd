extends Node3D

@export var mouseSens = 0.003
@export_range(-90, 0.0, 0.1, "radians_as_degrees") var maxAngle = PI/12
@export_range(-90, 0.0, 0.1, "radians_as_degrees") var minAngle = -PI/3	

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouseSens
		rotation.y = wrapf(rotation.y, 0.0, TAU)
		rotation.x -= event.relative.y * mouseSens
		rotation.x = clampf(rotation.x, minAngle, maxAngle)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
