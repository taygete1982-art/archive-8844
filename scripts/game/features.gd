extends RefCounted

const U = preload("res://scripts/game/util.gd")

static func build(root: Node2D, refs: Dictionary) -> Dictionary:
    var st := {}
    st.root = root
    st.bumps = refs.bumpers
    st.bump_cd = [0.0, 0.0, 0.0]
    var trail = Line2D.new()
    trail.width = 12
    trail.z_index = 9
    var gt = GradientTexture1D.new()
    var gr = Gradient.new()
    gr.set_color(0, Color(1, 0.8, 0.3, 0))
    gr.set_color(1, Color(1, 0.8, 0.3, 0.5))
    gt.gradient = gr
    trail.gradient = gt
    root.add_child(trail)
    st.trail = trail
    st.trail_pts = []
    st.roll_nodes = []
    st.roll_lit = [false, false, false]
    st.roll_cd = [0.0, 0.0, 0.0]
    var rps = [Vector2(330, 240), Vector2(510, 200), Vector2(690, 240)]
    for p in rps:
        var n = Node2D.new()
        n.position = p
        n.add_child(U.poly(Color(0.85, 0.65, 0.25, 1), U.ngon(16, 12)))
        n.add_child(U.poly(Color(0.05, 0.04, 0.03, 1), U.ngon(9, 12)))
        root.add_child(n)
        st.roll_nodes.append(n)
    st.stand_nodes = []
    st.stand_lit = [false, false, false, false]
    st.stand_cd = [0.0, 0.0, 0.0, 0.0]
    var sps = [Vector2(30, 1150), Vector2(30, 1300), Vector2(990, 1150), Vector2(990, 1300)]
    for p in sps:
        var n = Node2D.new()
        n.position = p
        var v = ColorRect.new()
        v.size = Vector2(14, 70)
        v.position = Vector2(-7, -35)
        v.color = Color(0.85, 0.65, 0.25, 1)
        n.add_child(v)
        root.add_child(n)
        st.stand_nodes.append(n)
    return st

static func tick(st: Dictionary, ball: RigidBody2D, delta: float) -> int:
    var gained := 0
    st.trail_pts.push_back(ball.global_position)
    if st.trail_pts.size() > 16:
        st.trail_pts.pop_front()
    st.trail.points = PackedVector2Array(st.trail_pts)
    for i in range(3):
        st.bump_cd[i] -= delta
        if st.bump_cd[i] <= 0 and st.bumps[i].global_position.distance_to(ball.global_position) < 45:
            st.bump_cd[i] = 0.2
            st.bumps[i].scale = Vector2(1.25, 1.25)
            var tws = st.root.create_tween()
            tws.tween_property(st.bumps[i], "scale", Vector2(1, 1), 0.2)
    for i in range(3):
        st.roll_cd[i] -= delta
        if st.roll_cd[i] <= 0 and ball.global_position.distance_to(st.roll_nodes[i].global_position) < 40:
            st.roll_cd[i] = 0.5
            if not st.roll_lit[i]:
                st.roll_lit[i] = true
                st.roll_nodes[i].get_child(1).color = Color(1, 0.9, 0.5)
                gained += 50
                if st.roll_lit[0] and st.roll_lit[1] and st.roll_lit[2]:
                    gained += 500
                    for j in range(3):
                        st.roll_lit[j] = false
                        st.roll_nodes[j].get_child(1).color = Color(0.05, 0.04, 0.03, 1)
    for i in range(4):
        st.stand_cd[i] -= delta
        if st.stand_cd[i] <= 0 and ball.global_position.distance_to(st.stand_nodes[i].global_position) < 45:
            st.stand_cd[i] = 0.5
            if not st.stand_lit[i]:
                st.stand_lit[i] = true
                st.stand_nodes[i].get_child(0).color = Color(1, 0.9, 0.5)
                gained += 75
                if st.stand_lit[0] and st.stand_lit[1] and st.stand_lit[2] and st.stand_lit[3]:
                    gained += 750
                    for j in range(4):
                        st.stand_lit[j] = false
                        st.stand_nodes[j].get_child(0).color = Color(0.85, 0.65, 0.25, 1)
    return gained
