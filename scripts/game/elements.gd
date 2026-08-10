extends RefCounted

const U = preload("res://scripts/game/util.gd")

static func cross(k: float) -> Array:
    var src := [Vector2(-20, -50), Vector2(20, -50), Vector2(20, -20), Vector2(50, -20), Vector2(50, 20), Vector2(20, 20), Vector2(20, 50), Vector2(-20, 50), Vector2(-20, 20), Vector2(-50, 20), Vector2(-50, -20), Vector2(-20, -20)]
    var out := []
    for q in src:
        out.append(q * k)
    return out

static func arrow(k: float) -> Array:
    var src := [Vector2(0, -60), Vector2(40, -10), Vector2(25, 0), Vector2(35, 40), Vector2(10, 30), Vector2(0, 50), Vector2(-10, 30), Vector2(-35, 40), Vector2(-25, 0), Vector2(-40, -10)]
    var out := []
    for q in src:
        out.append(q * k)
    return out

static func dimall(bumps: Array, lvs: Array, syms: Array):
    for b in bumps:
        b.get_child(1).visible = false
        b.get_child(2).color = Color(0.13, 0.11, 0.08, 1)
        b.get_child(3).color = Color(0.22, 0.18, 0.12, 1)
    for lv in lvs:
        lv.get_child(1).visible = false
        lv.get_child(2).color = Color(0.16, 0.13, 0.08, 1)
    for s in syms:
        s.get_child(0).visible = false
        s.get_child(1).color = Color(0.16, 0.13, 0.08, 1)
        s.get_child(2).color = Color(0.08, 0.06, 0.04, 1)

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
    var edge = U.poly(Color(0.35, 0.25, 0.15, 1), [Vector2(-180, -25), Vector2(180, -25), Vector2(180, -17), Vector2(-180, -17)])
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
    f.name = "LeftFlipper" if side > 0 else "RightFlipper"
    f.position = pos
    f.sync_to_physics = true
    root.add_child(f)
    
    var script = load("res://scripts/game/flipper_physics.gd")
    if script:
        f.set_script(script)
        f.side = side
        f.rest_angle = 30.0 if side > 0 else -30.0
        f.active_angle = -30.0 if side > 0 else 30.0
    
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
    f.add_child(U.poly(Color(0.05, 0.04, 0.03, 1), base_pts))
    f.add_child(U.poly(Color(0.25, 0.2, 0.12, 1), vis_pts))
    f.add_child(U.poly(Color(1, 0.8, 0.3, 1), edge_pts))
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
        var g = U.glow_sprite(U.radial_tex(Color(1, 0.8, 0.4, 0.35), Color(1, 0.8, 0.4, 0)), Vector2(0, 0), Vector2(1.2, 1.2))
        g.visible = false
        s.add_child(g)
        s.add_child(U.poly(Color(0.16, 0.13, 0.08, 1), arrow(0.5)))
        s.add_child(U.poly(Color(0.08, 0.06, 0.04, 1), arrow(0.22)))
        root.add_child(s)
        syms.append(s)
    refs.symbols = syms
    var thread = Line2D.new()
    thread.points = PackedVector2Array([Vector2(250, 550), Vector2(770, 550)])
    thread.width = 5
    thread.default_color = Color(1, 0.75, 0.35, 0.15)
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
        var g = U.glow_sprite(U.radial_tex(Color(1, 0.85, 0.4, 0.35), Color(1, 0.85, 0.4, 0)), Vector2(0, 0), Vector2(1.1, 1.1))
        g.visible = false
        lv.add_child(g)
        lv.add_child(U.poly(Color(0.16, 0.13, 0.08, 1), U.octagon(30)))
        lvs.append(lv)
    refs.lovers = lvs
    var warm = U.radial_tex(Color(1, 0.6, 0.2, 0.35), Color(1, 0.6, 0.2, 0))
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
        var g = U.glow_sprite(warm, Vector2(0, 0), Vector2(0.9, 0.9))
        g.visible = false
        b.add_child(g)
        b.add_child(U.poly(Color(0.13, 0.11, 0.08, 1), cross(0.46)))
        b.add_child(U.poly(Color(0.22, 0.18, 0.12, 1), cross(0.24)))
        bumps.append(b)
    refs.bumpers = bumps
    refs.flip_l = flipper(root, Vector2(250, 1650), 1)
    refs.flip_r = flipper(root, Vector2(770, 1650), -1)
    dimall(refs.bumpers, refs.lovers, refs.symbols)
    return refs
