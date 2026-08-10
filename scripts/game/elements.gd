extends RefCounted

const U = preload("res://scripts/game/util.gd")

static func slingshot(root, pos, rot) -> Dictionary:
	var f = StaticBody2D.new()
	f.position = pos
	f.rotation = rot
	root.add_child(f)
	var c = CollisionShape2D.new()
	var s = RectangleShape2D.new()
	s.size = Vector2(360, 50)
	c.shape = s
	f.add_child(c)
	var v = ColorRect.new()
	v.size = Vector2(360, 50)
	v.position = Vector2(-180, -25)
	v.color = Color(0.35, 0.25, 0.15, 1)
	f.add_child(v)
	var edge = U.poly(Color(0.85, 0.45, 0.15, 1), [Vector2(-180, -25), Vector2(180, -25), Vector2(180, -17), Vector2(-180, -17)])
	f.add_child(edge)
	var area = Area2D.new()
	area.position = Vector2(-10, -36)
	f.add_child(area)
	var ac = CollisionShape2D.new()
	var ashape = RectangleShape2D.new()
	ashape.size = Vector2(300, 18)
	ac.shape = ashape
	area.add_child(ac)
	var normal = Vector2(0, -1).rotated(rot)
	return {area = area, edge = edge, normal = normal, cd = 0.0}

static func flipper(root, pos, side) -> AnimatableBody2D:
	var f = AnimatableBody2D.new()
	f.position = pos
	f.sync_to_physics = true
	root.add_child(f)
	var c = CollisionShape2D.new()
	var s = RectangleShape2D.new()
	s.size = Vector2(250, 40)
	c.shape = s
	c.position = Vector2(125 * side, 0)
	f.add_child(c)
	var base_pts := [Vector2(0, -17), Vector2(250, -10), Vector2(250, 10), Vector2(0, 17)]
	var vis_pts := [Vector2(2, -14), Vector2(248, -8), Vector2(248, 8), Vector2(2, 14)]
	var edge_pts := [Vector2(2, -14), Vector2(248, -8), Vector2(248, -5), Vector2(2, -10)]
	if side < 0:
		base_pts = U.mirror(base_pts)
		vis_pts = U.mirror(vis_pts)
		edge_pts = U.mirror(edge_pts)
	f.add_child(U.poly(Color(0.3, 0.22, 0.14, 1), base_pts))
	f.add_child(U.poly(Color(0.55, 0.4, 0.25, 1), vis_pts))
	f.add_child(U.poly(Color(0.85, 0.45, 0.15, 1), edge_pts))
	return f

static func build(root: Node2D) -> Dictionary:
	var refs := {}

	refs.slings = [
		slingshot(root, Vector2(128, 1517), 0.825),
		slingshot(root, Vector2(892, 1517), -0.825)
	]

	var syms := []
	for p in [Vector2(150, 700), Vector2(870, 700), Vector2(510, 320)]:
		var s = Node2D.new()
		s.position = p
		s.add_child(U.glow_sprite(U.radial_tex(Color(0.85, 0.45, 0.15, 0.2), Color(0.85, 0.45, 0.15, 0)), Vector2(0, 0), Vector2(1.2, 1.2)))
		s.add_child(U.poly(Color(0.7, 0.45, 0.2, 1), [Vector2(0, -28), Vector2(28, 0), Vector2(0, 28), Vector2(-28, 0)]))
		s.add_child(U.poly(Color(0.3, 0.22, 0.14, 1), [Vector2(0, -12), Vector2(12, 0), Vector2(0, 12), Vector2(-12, 0)]))
		root.add_child(s)
		syms.append(s)
	refs.symbols = syms

	var thread = Line2D.new()
	thread.points = PackedVector2Array([Vector2(250, 550), Vector2(770, 550)])
	thread.width = 5
	thread.default_color = Color(0.7, 0.45, 0.2, 0.5)
	root.add_child(thread)
	refs.thread = thread

	var lvs := []
	for p in [Vector2(250, 550), Vector2(770, 550)]:
		var lv = StaticBody2D.new()
		lv.position = p
		root.add_child(lv)
		var c = CollisionShape2D.new()
		var cs = CircleShape2D.new()
		cs.radius = 30
		c.shape = cs
		lv.add_child(c)
		lv.add_child(U.glow_sprite(U.radial_tex(Color(0.85, 0.5, 0.2, 0.2), Color(0.85, 0.5, 0.2, 0)), Vector2(0, 0), Vector2(1.1, 1.1)))
		lv.add_child(U.poly(Color(0.85, 0.45, 0.15, 1), U.octagon(30)))
		lvs.append(lv)
	refs.lovers = lvs

	var warm = U.radial_tex(Color(0.8, 0.4, 0.2, 0.2), Color(0.8, 0.4, 0.2, 0))
	var bumps := []
	for p in [Vector2(510, 800), Vector2(370, 950), Vector2(650, 950)]:
		var b = StaticBody2D.new()
		b.position = p
		root.add_child(b)
		var c = CollisionShape2D.new()
		var cs = CircleShape2D.new()
		cs.radius = 25
		c.shape = cs
		b.add_child(c)
		b.add_child(U.glow_sprite(warm, Vector2(0, 0), Vector2(0.9, 0.9)))
		b.add_child(U.poly(Color(0.75, 0.4, 0.25, 1), U.octagon(22)))
		bumps.append(b)
	refs.bumpers = bumps

	refs.flip_l = flipper(root, Vector2(250, 1650), 1)
	refs.flip_r = flipper(root, Vector2(770, 1650), -1)

	return refs