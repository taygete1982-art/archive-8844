extends RefCounted

var ball: RigidBody2D
var flip_l: AnimatableBody2D
var flip_r: AnimatableBody2D
var charge_l := 0.0
var charge_r := 0.0

const MAX_CHARGE := 1.0
const NEAR := 280.0

func setup(b: RigidBody2D, fl: AnimatableBody2D, fr: AnimatableBody2D):
	ball = b
	flip_l = fl
	flip_r = fr

func tick(delta: float, l_on: bool, r_on: bool):
	if l_on:
		charge_l = min(charge_l + delta * 0.8, MAX_CHARGE)
	else:
		charge_l = 0.0
	if r_on:
		charge_r = min(charge_r + delta * 0.8, MAX_CHARGE)
	else:
		charge_r = 0.0
	visual(flip_l, charge_l)
	visual(flip_r, charge_r)

func visual(f: AnimatableBody2D, c: float):
	var edge = f.get_child(3)
	edge.modulate = Color(1 + c * 3, 1 + c * 1.5, 1, 1)

func release(left: bool):
	var c = charge_l if left else charge_r
	var f = flip_l if left else flip_r
	if left:
		charge_l = 0.0
	else:
		charge_r = 0.0
	if ball == null:
		return
	if c > 0.15 and ball.global_position.distance_to(f.global_position) < NEAR:
		var dir = Vector2(0.35 if left else -0.35, -1).normalized()
		ball.apply_central_impulse(dir * (500 + 1300 * c))