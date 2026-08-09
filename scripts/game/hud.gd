extends RefCounted

static func make_label(size: int, color: Color, pos: Vector2, sz: Vector2) -> Label:
	var l = Label.new()
	l.position = pos
	l.size = sz
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = 1
	return l

static func build(root: Node2D) -> Dictionary:
	var refs := {}
	var hud = CanvasLayer.new()
	root.add_child(hud)
	var plate = ColorRect.new()
	plate.position = Vector2(70, 70)
	plate.size = Vector2(330, 180)
	plate.color = Color(0.05, 0.04, 0.03, 0.55)
	hud.add_child(plate)
	refs.score = make_label(56, Color(1, 0.8, 0.4), Vector2(90, 80), Vector2(290, 80))
	hud.add_child(refs.score)
	refs.balls = make_label(28, Color(1, 0.75, 0.35), Vector2(90, 160), Vector2(290, 45))
	hud.add_child(refs.balls)
	refs.syms = make_label(26, Color(1, 0.85, 0.5), Vector2(90, 205), Vector2(290, 40))
	hud.add_child(refs.syms)
	refs.overlay = make_label(52, Color(1, 0.9, 0.7), Vector2(90, 800), Vector2(900, 300))
	refs.overlay.vertical_alignment = 1
	refs.overlay.visible = false
	hud.add_child(refs.overlay)
	return refs

static func refresh(refs: Dictionary, score: int, balls: int, sym_lit):
	refs.score.text = str(score)
	var b = ""
	for i in range(balls):
		b += "●  "
	refs.balls.text = b
	var s = ""
	for i in range(3):
		s += "◆" if sym_lit[i] else "◇"
		if i < 2:
			s += "   "
	refs.syms.text = s

static func flash_score(refs: Dictionary):
	var node = refs.score
	node.modulate = Color(4, 4, 4, 1)
	if node.is_inside_tree():
		var tw = node.get_tree().create_tween()
		tw.tween_property(node, "modulate", Color(1, 1, 1, 1), 0.4)