extends RefCounted

const U = preload("res://scripts/game/util.gd")
const E = preload("res://scripts/game/elements.gd")
const Lane = preload("res://scripts/game/lane.gd")
const Atmosphere = preload("res://scripts/game/atmosphere.gd")

static func build(root: Node2D) -> Dictionary:
    Engine.physics_ticks_per_second = 360
    var refs := {}
    var bg = ColorRect.new()
    bg.color = Color(0.1, 0.13, 0.11, 1)
    bg.size = Vector2(1080, 1920)
    root.add_child(bg)

    var d1 = ColorRect.new()
    d1.size = Vector2(1020, 520)
    d1.position = Vector2(0, 0)
    d1.color = Color(0, 0, 0, 0.16)
    root.add_child(d1)
    var d2 = ColorRect.new()
    d2.size = Vector2(1020, 260)
    d2.position = Vector2(0, 0)
    d2.color = Color(0, 0, 0, 0.12)
    root.add_child(d2)

    U.gold_line(root, Color(0.85, 0.65, 0.2, 0.9), [Vector2(0, 0), Vector2(4, 0), Vector2(4, 1860), Vector2(0, 1860)])
    U.gold_line(root, Color(0.85, 0.65, 0.2, 0.9), [Vector2(1016, 0), Vector2(1020, 0), Vector2(1020, 1860), Vector2(1016, 1860)])
    U.gold_line(root, Color(0.85, 0.65, 0.2, 0.9), [Vector2(0, 0), Vector2(1020, 0), Vector2(1020, 4), Vector2(0, 4)])
    U.gold_line(root, Color(0.2, 0.8, 0.6, 0.9), [Vector2(0, 1856), Vector2(1020, 1856), Vector2(1020, 1860), Vector2(0, 1860)])

    U.gold_line(root, Color(0, 0, 0, 0.35), [Vector2(4, 0), Vector2(12, 0), Vector2(12, 1860), Vector2(4, 1860)])
    U.gold_line(root, Color(0, 0, 0, 0.35), [Vector2(1008, 0), Vector2(1016, 0), Vector2(1016, 1860), Vector2(1008, 1860)])
    U.gold_line(root, Color(0, 0, 0, 0.35), [Vector2(0, 4), Vector2(1020, 4), Vector2(1020, 12), Vector2(0, 12)])

    var hole = ColorRect.new()
    hole.size = Vector2(240, 50)
    hole.position = Vector2(390, 0)
    hole.color = Color(0.03, 0.04, 0.03, 1)
    root.add_child(hole)

    var gate = StaticBody2D.new()
    gate.position = Vector2(510, 30)
    root.add_child(gate)
    var gsh = CollisionShape2D.new()
    var gs = RectangleShape2D.new()
    gs.size = Vector2(240, 40)
    gsh.shape = gs
    gate.add_child(gsh)
    refs.gate_shape = gsh
    var gvis = ColorRect.new()
    gvis.size = Vector2(240, 40)
    gvis.position = Vector2(-120, -20)
    gvis.color = Color(0.2, 0.23, 0.2, 1)
    gate.add_child(gvis)
    refs.gate_vis = gvis
    var gseam = ColorRect.new()
    gseam.size = Vector2(240, 6)
    gseam.position = Vector2(-120, 14)
    gseam.color = Color(0.85, 0.65, 0.2, 0.9)
    gate.add_child(gseam)
    refs.gate_seam = gseam

    var walls = StaticBody2D.new()
    root.add_child(walls)
    U.wall(walls, Vector2(-20, 960), Vector2(40, 1920))
    U.wall(walls, Vector2(1100, 960), Vector2(40, 1920))
    U.wall(walls, Vector2(195, -20), Vector2(390, 40))
    U.wall(walls, Vector2(855, -20), Vector2(450, 40))
    U.wall(walls, Vector2(540, 1940), Vector2(1080, 40))

    var el = E.build(root)
    refs.slings = el.slings
    refs.symbols = el.symbols
    refs.thread = el.thread
    refs.lovers = el.lovers
    refs.bumpers = el.bumpers
    refs.flip_l = el.flip_l
    refs.flip_r = el.flip_r

    var ball = RigidBody2D.new()
    ball.mass = 3.5
    ball.can_sleep = false
    ball.continuous_cd = 1
    ball.gravity_scale = 1.8
    ball.linear_damp_mode = RigidBody2D.DAMP_MODE_REPLACE
    ball.linear_damp = 0.03
    var bpm = PhysicsMaterial.new()
    bpm.bounce = 0.2
    bpm.friction = 0.05
    ball.physics_material_override = bpm
    root.add_child(ball)
    var bc = CollisionShape2D.new()
    var bs = CircleShape2D.new()
    bs.radius = 18
    bc.shape = bs
    ball.add_child(bc)
    var bsh = U.poly(Color(0, 0, 0, 0.3), U.ngon(18, 12))
    bsh.position = Vector2(6, 14)
    ball.add_child(bsh)
    ball.add_child(U.poly(Color(0.85, 0.65, 0.2, 1), U.ngon(20, 12)))
    ball.add_child(U.poly(Color(0.3, 0.9, 0.7, 1), U.ngon(18, 12)))
    refs.ball = ball

    refs.lane = Lane.build(root)
    refs.fx = Atmosphere.build(root, refs)

    return refs
