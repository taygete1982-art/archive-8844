extends StaticBody2D

@export var hit_score := 100

var cd := 0.0
var ball_was_inside := false
var is_lit := false
var lit_glow: Sprite2D = null

func _ready():
	add_to_group("bumpers")

	lit_glow = Sprite2D.new()
	var g = Gradient.new()
	g.colors = PackedColorArray([Color(1, 0.35, 0.2, 0.75), Color(1, 0.35, 0.2, 0)])
	var gt = GradientTexture2D.new()
	gt.gradient = g
	gt.fill = 1
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(0.5, 0)
	gt.width = 96
	gt.height = 96
	lit_glow.texture = gt
	var mat = CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	lit_glow.material = mat
	lit_glow.scale = Vector2(1.2, 1.2)
	lit_glow.visible = false
	add_child(lit_glow)
	move_child(lit_glow, 0)

func _process(delta):
	cd -= delta
	var ball = get_tree().current_scene.get_node_or_null("Ball")
	if ball == null:
		return
	var d = global_position.distance_to(ball.global_position)

	if d < 45:
		if not ball_was_inside:
			ball_was_inside = true
			cd = 0.2
			_pop(ball, true)
		elif cd <= 0:
			cd = 0.2
			_pop(ball, false)
	else:
		ball_was_inside = false

func _pop(body, first_hit: bool):
	if not is_lit:
		_light_up()
	var dir = (body.global_position - global_position).normalized()
	if dir.length() < 0.1:
		dir = Vector2(0, -1)
	# Случайный угол — чтобы удар в центр не держал мяч на месте
	dir = dir.rotated(randf_range(-0.4, 0.4))
	body.apply_central_impulse(dir * 500)

	var fx = get_node_or_null("/root/FX")
	if fx:
		fx.ring(global_position, Color(1, 0.6, 0.2), 1.6)
		fx.shake(5)

	if first_hit:
		var sm = get_node_or_null("/root/ScoreManager")
		if sm:
			sm.add_score(hit_score)
		if fx:
			fx.float_text(global_position + Vector2(0, -45), "+" + str(hit_score), Color(1, 0.6, 0.4))

	var visual = get_node_or_null("Visual")
	if visual:
		visual.scale = Vector2(1.4, 1.4)
		visual.modulate = Color(3, 3, 3, 1)
		var tw = visual.create_tween()
		tw.tween_property(visual, "scale", Vector2(1, 1), 0.2)
		tw.parallel().tween_property(visual, "modulate", Color(1, 1, 1, 1), 0.2)

func _light_up():
	is_lit = true
	if lit_glow:
		lit_glow.visible = true
	var core = get_node_or_null("Core")
	if core:
		core.color = Color(1, 0.4, 0.2, 1)
	var scene = get_tree().current_scene
	if scene:
		var bumpers = get_tree().get_nodes_in_group("bumpers")
		var all_lit = true
		for b in bumpers:
			if b != self and not b.get("is_lit"):
				all_lit = false
				break
		if all_lit and bumpers.size() >= 3:
			var sm = get_node_or_null("/root/ScoreManager")
			if sm and sm.has_method("complete_level"):
				sm.complete_level()

func _light_down():
	is_lit = false
	if lit_glow:
		lit_glow.visible = false
	var core = get_node_or_null("Core")
	if core:
		core.color = Color(1, 0.62, 0.18, 1)