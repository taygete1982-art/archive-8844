extends RefCounted

const LANE_X := 1050.0
const LANE_WALL_X := 1020.0

static func build(root: Node2D) -> Dictionary:
	var refs := {}

	var wall = StaticBody2D.new()
	root.add_child(wall)
	var c = CollisionShape2D.new()
	var s = RectangleShape2D.new()
	s.size = Vector2(12, 1550)
	c.shape = s
	c.position = Vector2(LANE_WALL_X, 1095)
	wall.add_child(c)
	var v = ColorRect.new()
	v.size = Vector2(12, 1550)
	v.position = Vector2(LANE_WALL_X - 6, 320)
	v.color = Color(0.16, 0.12, 0.09, 1)
	wall.add_child(v)

	var body = StaticBody2D.new()
	body.position = Vector2(LANE_X, 1885)
	root.add_child(body)
	var bc = CollisionShape2D.new()
	var bs = RectangleShape2D.new()
	bs.size = Vector2(56, 70)
	bc.shape = bs
	body.add_child(bc)

	var pl = ColorRect.new()
	pl.size = Vector2(56, 90)
	pl.position = Vector2(LANE_X - 28, 1830)
	pl.color = Color(0.45, 0.3, 0.15, 1)
	root.add_child(pl)
	refs.plunger_vis = pl

	return refs