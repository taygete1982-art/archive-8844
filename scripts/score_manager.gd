extends Node

signal score_changed(new_score)
signal balls_changed(balls_left)
signal game_over
signal game_restarted
signal level_completed

var score := 0
var balls := 3
var is_level_complete := false

func _ready():
	Engine.physics_ticks_per_second = 180

func _input(event):
	var pressed: bool
	var left_side: bool

	if event is InputEventKey:
		if event.keycode == KEY_LEFT or event.keycode == KEY_A:
			left_side = true
		elif event.keycode == KEY_RIGHT or event.keycode == KEY_D:
			left_side = false
		else:
			return
		pressed = event.pressed
	elif event is InputEventScreenTouch or event is InputEventMouseButton:
		if event is InputEventMouseButton and event.button_index != MOUSE_BUTTON_LEFT:
			return
		pressed = event.pressed
		left_side = event.position.x < get_viewport().get_visible_rect().size.x * 0.5
	else:
		return

	var lf = get_tree().current_scene.get_node_or_null("LeftFlipper")
	var rf = get_tree().current_scene.get_node_or_null("RightFlipper")

	if left_side:
		_drive(lf, pressed)
	else:
		_drive(rf, pressed)

func _drive(flipper, pressed: bool):
	if flipper == null:
		return
	if flipper.has_method("set_active"):
		flipper.set_active(pressed)
	elif "is_active" in flipper:
		flipper.is_active = pressed
	else:
		flipper.set("is_active", pressed)

func add_score(points: int):
	score += points
	score_changed.emit(score)

func lose_ball():
	balls -= 1
	balls_changed.emit(balls)
	if balls <= 0:
		game_over.emit()

func complete_level():
	if is_level_complete:
		return
	is_level_complete = true
	add_score(1000)
	level_completed.emit()

func start_new_game():
	score = 0
	balls = 3
	is_level_complete = false
	score_changed.emit(score)
	balls_changed.emit(balls)
	game_restarted.emit()
	# Гасим все бамперы
	for b in get_tree().get_nodes_in_group("bumpers"):
		if b.has_method("_light_down"):
			b._light_down()