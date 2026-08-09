extends AnimatableBody2D

@export var rest_angle := 30.0
@export var active_angle := -30.0
@export var speed := 15.0

var is_active := false
var angle := 0.0

func _ready():
	print("=== FLIPPER READY ===")
	angle = rest_angle
	rotation_degrees = angle

func _physics_process(delta):
	var target = active_angle if is_active else rest_angle
	angle = lerp(angle, target, speed * delta)
	rotation_degrees = angle

func set_active(value: bool):
	is_active = value