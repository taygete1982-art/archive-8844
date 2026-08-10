extends RefCounted

var root: Node2D
var tracks := []
var record_t := 0.0
var dust_t := 0.0
var last_pos := Vector2(-9999, -9999)

const PRINT_LIFE := 3.0
const PRINT_GAP := 24.0
const BOOST := 220.0
const DUST_SPEED := 500.0

func setup(r: Node2D):
	root = r

func clear():
	for p in tracks:
		p.node.queue_free()
	tracks.clear()
	last_pos = Vector2(-9999, -9999)

func tick(delta: float, ball: RigidBody2D):
	if ball == null or root == null:
		return
	var pos = ball.global_position
	var speed = ball.linear_velocity.length()

	record_t -= delta
	if record_t <= 0 and speed > 60 and pos.distance_to(last_pos) > PRINT_GAP:
		record_t = 0.06
		last_pos = pos
		add_print(pos)

	for i in range(tracks.size() - 1, -1, -1):
		var p = tracks[i]
		p.age += delta
		var k = 1.0 - (p.age / PRINT_LIFE)
		if k <= 0:
			p.node.queue_free()
			tracks.remove_at(i)
			continue
		p.node.modulate.a = 0.35 * k
		if not p.used and p.age > 0.4 and pos.distance_to(p.pos) < 18:
			p.used = true
			var dir = ball.linear_velocity.normalized()
			if dir.length() > 0.1:
				ball.apply_central_impulse(dir * BOOST)
			puff(pos, 4)

	dust_t -= delta
	if speed > DUST_SPEED and dust_t <= 0:
		dust_t = 0.12
		puff(pos, 2)

func add_print(pos: Vector2):
	var n = Polygon2D.new()
	var pts = PackedVector2Array()
	for i in range(6):
		var a = i * TAU / 6.0
		pts.append(Vector2(cos(a), sin(a)) * 7)
	n.polygon = pts
	n.color = Color(0.35, 0.26, 0.17, 1)
	n.global_position = pos
	root.add_child(n)
	tracks.append({node = n, pos = pos, age = 0.0, used = false})
	if tracks.size() > 50:
		var old = tracks.pop_front()
		old.node.queue_free()

func puff(pos: Vector2, count: int):
	for i in range(count):
		var d = Polygon2D.new()
		var pts = PackedVector2Array()
		for k in range(6):
			var a = k * TAU / 6.0
			pts.append(Vector2(cos(a), sin(a)) * randf_range(3, 6))
		d.polygon = pts
		d.color = Color(0.8, 0.7, 0.55, 0.5)
		d.global_position = pos + Vector2(randf_range(-8, 8), randf_range(-8, 8))
		root.add_child(d)
		var tw = root.create_tween()
		tw.tween_property(d, "modulate:a", 0.0, 0.5)
		tw.parallel().tween_property(d, "scale", Vector2(2.2, 2.2), 0.5)
		tw.tween_callback(d.queue_free)
