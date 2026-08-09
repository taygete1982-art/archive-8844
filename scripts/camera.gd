extends Camera2D

var shake_power := 0.0

func _ready():
	enabled = true
	make_current()
	anchor_mode = ANCHOR_MODE_DRAG_CENTER
	position = Vector2(540, 960)
	add_to_group("main_camera")

func add_shake(s: float):
	shake_power = min(shake_power + s, 20.0)

func _physics_process(_delta):
	if shake_power > 0.2:
		shake_power = lerp(shake_power, 0.0, 0.1)
		offset = Vector2(randf_range(-shake_power, shake_power), randf_range(-shake_power, shake_power))
	else:
		offset = Vector2.ZERO