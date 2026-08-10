extends RefCounted

var H = preload("res://scripts/game/hud.gd")
var A = preload("res://scripts/game/atmosphere.gd")

var t = null
var bump_lit := [false, false, false]
var bump_cd := [0.0, 0.0, 0.0]
var lover_hit := [false, false]
var sym_lit := [false, false, false]

func tick(delta):
	for s in t.slings:
		s.cd -= delta
		if s.cd <= 0 and s.area.get_overlapping_bodies().has(t.ball):
			s.cd = 0.25
			t.ball.apply_central_impulse(s.normal * 800)
			add(10)
			s.edge.modulate = Color(4, 4, 4, 1)
			var tw = t.root.create_tween()
			tw.tween_property(s.edge, "modulate", Color(1, 1, 1, 1), 0.2)

	for i in range(3):
		bump_cd[i] -= delta
		if t.bumpers[i].global_position.distance_to(t.ball.global_position) < 45 and bump_cd[i] <= 0:
			bump_cd[i] = 0.2
			var dir = (t.ball.global_position - t.bumpers[i].global_position).normalized()
			if dir.length() < 0.1:
				dir = Vector2(0, -1)
			dir = dir.rotated(randf_range(-0.2, 0.2))
			t.ball.apply_central_impulse(dir * 650)
			t.bumpers[i].get_child(1).modulate = Color(4, 4, 4, 1)
			var twb = t.root.create_tween()
			twb.tween_property(t.bumpers[i].get_child(1), "modulate", Color(1, 1, 1, 1), 0.2)
			if t.hot and not bump_lit[i]:
				bump_lit[i] = true
				t.bumpers[i].get_child(2).color = Color(0.9, 0.35, 0.1)
				add(100)
				if bump_lit[0] and bump_lit[1] and bump_lit[2]:
					add(1000)
					t.win()

	for i in range(2):
		if t.hot and not lover_hit[i] and t.lovers[i].global_position.distance_to(t.ball.global_position) < 55:
			lover_hit[i] = true
			var dir = (t.ball.global_position - t.lovers[i].global_position).normalized()
			dir = dir.rotated(randf_range(-0.4, 0.4))
			t.ball.apply_central_impulse(dir * 500)
			t.lovers[i].get_child(2).color = Color(0.9, 0.5, 0.15)
			t.thread.default_color = Color(0.9, 0.5, 0.15, 0.9)
			if lover_hit[0] and lover_hit[1]:
				add(500)
				lover_hit = [false, false]
				t.lovers[0].get_child(2).color = Color(0.85, 0.65, 0.25)
				t.lovers[1].get_child(2).color = Color(0.85, 0.65, 0.25)
				t.thread.default_color = Color(0.7, 0.45, 0.2, 0.5)
			else:
				var twl = t.root.create_tween()
				twl.tween_interval(2.0)
				twl.tween_callback(func():
					if lover_hit[0] != lover_hit[1]:
						lover_hit = [false, false]
						t.lovers[0].get_child(2).color = Color(0.85, 0.65, 0.25)
						t.lovers[1].get_child(2).color = Color(0.85, 0.65, 0.25)
						t.thread.default_color = Color(0.7, 0.45, 0.2, 0.5))

	for i in range(3):
		if t.hot and not sym_lit[i] and t.symbols[i].get_child(1).global_position.distance_to(t.ball.global_position) < 50:
			sym_lit[i] = true
			t.symbols[i].get_child(1).color = Color(0.95, 0.6, 0.2)
			add(50)
			A.progress(t.fx, sym_lit)
			if sym_lit[0] and sym_lit[1] and sym_lit[2]:
				t.gate_open = true
				t.gate_shape.disabled = true
				t.gate_vis.visible = false
				t.gate_seam.visible = false
				A.attic_open(t.fx)

	if t.gate_open and t.ball.global_position.y < 20 and t.ball.global_position.x > 390 and t.ball.global_position.x < 630:
		add(500)
		t.respawn()

func add(n: int):
	t.score += n
	H.refresh(t.hud, t.score, t.balls, sym_lit)

func reset():
	bump_lit = [false, false, false]
	lover_hit = [false, false]
	sym_lit = [false, false, false]
	for i in range(3):
		t.bumpers[i].get_child(2).color = Color(0.75, 0.4, 0.25)
		t.symbols[i].get_child(1).color = Color(0.7, 0.45, 0.2)
	t.thread.default_color = Color(0.7, 0.45, 0.2, 0.5)