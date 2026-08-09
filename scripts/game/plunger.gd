extends RefCounted

var ball: RigidBody2D
var vis: ColorRect
var charge := 0.0
var charging := false
var is_launching := false

const LANE_X := 1020.0
const SWEET_MIN := 0.55
const SWEET_MAX := 0.85

func setup(b: RigidBody2D, v: ColorRect):
	ball = b
	vis = v

func ball_in_lane() -> bool:
	return ball != null and ball.global_position.x > LANE_X

func set_charging(on: bool):
	charging = on
	if not on:
		charge = 0.0

func tick(delta: float):
	if charging and ball_in_lane():
		charge = min(charge + delta / 1.2, 1.0)
	if vis:
		vis.size = Vector2(56, 90 - 50 * charge)
		vis.position = Vector2(1022, 1830 + 50 * charge)
		vis.color = Color(0.45 + 0.5 * charge, 0.3, 0.15, 1)

func launch() -> bool:
	if ball == null or not ball_in_lane():
		return false
	var c = charge
	charge = 0.0
	charging = false
	is_launching = true
	ball.linear_velocity = Vector2(0, -(1800 + 1200 * c))
	return c >= SWEET_MIN and c <= SWEET_MAX

func check_launch_end():
	if is_launching and not ball_in_lane():
		is_launching = false