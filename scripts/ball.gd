extends RigidBody2D

func _ready():
	print("========================================")
	print("=== BALL READY ===")
	print("========================================")
	linear_velocity = Vector2(randf_range(-200, 200), 0)

func _physics_process(_delta):
	if linear_velocity.length() < 30:
		apply_central_impulse(Vector2(randf_range(-300, 300), randf_range(-400, -200)))
