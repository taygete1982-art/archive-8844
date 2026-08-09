extends Node

func float_text(pos: Vector2, text: String, color: Color = Color(1, 0.92, 0.75)):
	var root = get_tree().current_scene
	if root == null:
		return
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 42)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = pos - Vector2(110, 20)
	label.size = Vector2(220, 60)
	root.add_child(label)
	var tw = create_tween()
	tw.tween_property(label, "position:y", label.position.y - 90, 0.9)
	tw.parallel().tween_property(label, "modulate:a", 0.0, 0.9)
	tw.tween_callback(label.queue_free)

func ring(pos: Vector2, color: Color = Color(1, 0.75, 0.35), max_scale: float = 2.4):
	var root = get_tree().current_scene
	if root == null:
		return
	var line = Line2D.new()
	line.width = 5.0
	line.default_color = color
	var pts = PackedVector2Array()
	for i in range(25):
		var a = i * TAU / 24.0
		pts.append(Vector2(cos(a), sin(a)) * 22.0)
	line.points = pts
	line.position = pos
	root.add_child(line)
	var tw = line.create_tween()
	tw.tween_property(line, "scale", Vector2(max_scale, max_scale), 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(line, "modulate:a", 0.0, 0.45)
	tw.tween_callback(line.queue_free)
	# Кольцо всегда рождает сноп искр
	sparks(pos, color)

func sparks(pos: Vector2, color: Color = Color(1, 0.8, 0.3)):
	var root = get_tree().current_scene
	if root == null:
		return
	var p = GPUParticles2D.new()
	p.amount = 12
	p.lifetime = 0.35
	p.one_shot = true
	p.emitting = true
	p.explosiveness = 0.9
	var m = ParticleProcessMaterial.new()
	m.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	m.emission_sphere_radius = 3.0
	m.spread = 180.0
	m.gravity = Vector3(0, 1100, 0)
	m.initial_velocity_min = 180.0
	m.initial_velocity_max = 420.0
	m.scale_min = 1.2
	m.scale_max = 2.4
	m.color = color
	p.process_material = m
	var g = Gradient.new()
	g.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	var gt = GradientTexture2D.new()
	gt.gradient = g
	gt.fill = 1
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(0.5, 0)
	gt.width = 16
	gt.height = 16
	p.texture = gt
	p.position = pos
	root.add_child(p)
	await get_tree().create_timer(0.5).timeout
	p.queue_free()

func shake(strength: float = 6.0):
	var cam = get_tree().get_first_node_in_group("main_camera")
	if cam and cam.has_method("add_shake"):
		cam.add_shake(strength)