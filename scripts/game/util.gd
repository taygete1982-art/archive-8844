extends RefCounted

static func octagon(r: float):
	var pts := []
	for i in range(8):
		var a = i * TAU / 8.0 + TAU / 16.0
		pts.append(Vector2(cos(a), sin(a)) * r)
	return pts

static func ngon(r: float, n: int):
	var pts := []
	for i in range(n):
		var a = i * TAU / float(n)
		pts.append(Vector2(cos(a), sin(a)) * r)
	return pts

static func poly(color: Color, pts) -> Polygon2D:
	var p = Polygon2D.new()
	p.color = color
	var arr = PackedVector2Array()
	for pt in pts:
		arr.append(pt)
	p.polygon = arr
	return p

static func mirror(pts):
	var m := []
	for p in pts:
		m.append(Vector2(-p.x, p.y))
	return m

static func add_mat() -> CanvasItemMaterial:
	var m = CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return m

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

static func glow_sprite(tex, pos, scale) -> Sprite2D:
	var s = Sprite2D.new()
	s.texture = tex
	s.material = add_mat()
	s.position = pos
	s.scale = scale
	return s

static func wall(body, pos, size):
	var c = CollisionShape2D.new()
	var s = RectangleShape2D.new()
	s.size = size
	c.shape = s
	c.position = pos
	body.add_child(c)

static func gold_line(root, color: Color, pts):
	root.add_child(poly(color, pts))