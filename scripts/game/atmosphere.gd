extends RefCounted

static func radial_tex(c1: Color, c2: Color) -> GradientTexture2D:
	var g = Gradient.new()
	g.colors = PackedColorArray([c1, c2])
	var gt = GradientTexture2D.new()
	gt.gradient = g
	gt.fill = 1
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(0.5, 0)
	gt.width = 256
	gt.height = 256
	return gt

static func octagon(r: float):
	var pts := []
	for i in range(8):
		var a = i * TAU / 8.0 + TAU / 16.0
		pts.append(Vector2(cos(a), sin(a)) * r)
	return pts

static func add_occluder(parent, pts):
	var n = LightOccluder2D.new()
	var o = OccluderPolygon2D.new()
	var arr = PackedVector2Array()
	for p in pts:
		arr.append(p)
	o.polygon = arr
	n.occluder = o
	parent.add_child(n)

static func build(root: Node2D, refs: Dictionary) -> Dictionary:
	var fx := {}
	var gold = radial_tex(Color(1, 0.85, 0.5, 1), Color(1, 0.85, 0.5, 0))

	var key = PointLight2D.new()
	key.position = Vector2(510, 140)
	key.energy = 0.9
	key.texture = gold
	key.texture_scale = 4.0
	key.shadow_enabled = true
	key.color = Color(1, 0.85, 0.55, 1)
	root.add_child(key)
	fx.key = key

	var fill = PointLight2D.new()
	fill.position = Vector2(510, 960)
	fill.energy = 0.12
	fill.texture = gold
	fill.texture_scale = 10.0
	fill.color = Color(0.9, 0.75, 0.5, 1)
	root.add_child(fill)

	var cold = radial_tex(Color(0.6, 0.85, 1, 1), Color(0.6, 0.85, 1, 0))
	var rim = PointLight2D.new()
	rim.position = Vector2(510, 1880)
	rim.energy = 0.3
	rim.texture = cold
	rim.texture_scale = 4.0
	rim.color = Color(0.6, 0.85, 1, 1)
	root.add_child(rim)

	add_occluder(root, [Vector2(0, 0), Vector2(8, 0), Vector2(8, 1920), Vector2(0, 1920)])
	add_occluder(root, [Vector2(1012, 0), Vector2(1020, 0), Vector2(1020, 1920), Vector2(1012, 1920)])
	add_occluder(root, [Vector2(0, 0), Vector2(1020, 0), Vector2(1020, 8), Vector2(0, 8)])
	add_occluder(root, [Vector2(0, 1852), Vector2(1020, 1852), Vector2(1020, 1860), Vector2(0, 1860)])
	if refs.has("flip_l"):
		add_occluder(refs.flip_l, [Vector2(0, -17), Vector2(250, -10), Vector2(250, 10), Vector2(0, 17)])
	if refs.has("flip_r"):
		add_occluder(refs.flip_r, [Vector2(0, -17), Vector2(-250, -10), Vector2(-250, 10), Vector2(0, 17)])
	if refs.has("bumpers"):
		for b in refs.bumpers:
			add_occluder(b, octagon(25))
	if refs.has("lovers"):
		for lv in refs.lovers:
			add_occluder(lv, octagon(30))
	if refs.has("ball"):
		add_occluder(refs.ball, octagon(18))
		var bl = PointLight2D.new()
		bl.energy = 0.5
		bl.texture = radial_tex(Color(1, 0.95, 0.8, 0.6), Color(1, 0.95, 0.8, 0))
		bl.texture_scale = 1.6
		bl.shadow_enabled = true
		bl.color = Color(1, 0.95, 0.8, 1)
		refs.ball.add_child(bl)
		var sh = Polygon2D.new()
		sh.color = Color(0, 0, 0, 0.4)
		var pts = PackedVector2Array()
		for p in octagon(18):
			pts.append(p)
		sh.polygon = pts
		sh.position = Vector2(5, 7)
		sh.z_index = -1
		refs.ball.add_child(sh)

	var sym_lights := []
	for p in [Vector2(150, 700), Vector2(870, 700), Vector2(510, 320)]:
		var l = PointLight2D.new()
		l.position = p
		l.energy = 0.35
		l.texture = gold
		l.texture_scale = 1.5
		l.color = Color(1, 0.8, 0.4, 1)
		l.visible = false
		root.add_child(l)
		sym_lights.append(l)
	fx.sym_lights = sym_lights

	var attic_light = PointLight2D.new()
	attic_light.position = Vector2(510, 60)
	attic_light.energy = 0.6
	attic_light.texture = gold
	attic_light.texture_scale = 2.0
	attic_light.color = Color(1, 0.9, 0.6, 1)
	attic_light.visible = false
	root.add_child(attic_light)
	fx.attic_light = attic_light

	var fog = GPUParticles2D.new()
	fog.position = Vector2(510, 90)
	fog.amount = 25
	fog.lifetime = 6.0
	var fm = ParticleProcessMaterial.new()
	fm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	fm.emission_box_extents = Vector3(140, 50, 1)
	fm.direction = Vector3(0, -1, 0)
	fm.initial_velocity_min = 8.0
	fm.initial_velocity_max = 20.0
	fm.scale_min = 2.0
	fm.scale_max = 4.0
	fm.color = Color(1, 0.9, 0.7, 0.08)
	fog.process_material = fm
	root.add_child(fog)
	fx.fog = fog

	var dust = GPUParticles2D.new()
	dust.position = Vector2(510, 960)
	dust.amount = 50
	dust.lifetime = 10.0
	var pm = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(500, 900, 1)
	pm.initial_velocity_min = 5.0
	pm.initial_velocity_max = 15.0
	pm.scale_min = 1.0
	pm.scale_max = 3.0
	pm.color = Color(1, 0.8, 0.4, 0.1)
	dust.process_material = pm
	root.add_child(dust)

	var haze = ColorRect.new()
	haze.size = Vector2(1080, 1920)
	var hsh = load("res://assets/shaders/heat_haze.gdshader")
	if hsh:
		var hmat = ShaderMaterial.new()
		hmat.shader = hsh
		hmat.set_shader_parameter("speed", 0.06)
		hmat.set_shader_parameter("intensity", 0.05)
		hmat.set_shader_parameter("frequency", 6.0)
		haze.material = hmat
	root.add_child(haze)

	return fx

static func progress(fx: Dictionary, sym_lit):
	var lit = 0
	for i in range(3):
		fx.sym_lights[i].visible = sym_lit[i]
		if sym_lit[i]:
			lit += 1
	fx.key.energy = 0.9 + lit * 0.2
	fx.key.color = Color(1.0, 0.85 - lit * 0.08, 0.55 - lit * 0.12, 1)

static func attic_open(fx: Dictionary):
	fx.attic_light.visible = true
	fx.key.energy += 0.4

static func reset_fx(fx: Dictionary):
	fx.attic_light.visible = false
	for l in fx.sym_lights:
		l.visible = false
	fx.key.energy = 0.9
	fx.key.color = Color(1, 0.85, 0.55, 1)