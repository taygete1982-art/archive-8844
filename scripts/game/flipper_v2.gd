extends AnimatableBody2D

# Обновленный контроллер флиппера
# Использует lerp для плавности и стабильности

@export var rest_angle: float = 30.0
@export var active_angle: float = -30.0
@export var speed: float = 20.0

var is_active: bool = false
var current_angle: float = 0.0

func _ready():
	current_angle = rest_angle
	rotation_degrees = current_angle

func _physics_process(delta):
	var target = active_angle if is_active else rest_angle
	current_angle = lerp(current_angle, target, speed * delta)
	rotation_degrees = current_angle

func set_active(value: bool):
	is_active = value
