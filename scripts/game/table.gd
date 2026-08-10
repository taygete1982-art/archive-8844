extends RefCounted

var W = preload("res://scripts/game/world.gd")
var H = preload("res://scripts/game/hud.gd")
var B = preload("res://scripts/game/biome_desert.gd")
var C = preload("res://scripts/game/flipper_charge.gd")
var P = preload("res://scripts/game/plunger.gd")
var A = preload("res://scripts/game/atmosphere.gd")
var F = preload("res://scripts/game/features.gd")

var root: Node2D
var ball: RigidBody2D
var flip_l: AnimatableBody2D
var flip_r: AnimatableBody2D
var gate_shape: CollisionShape2D
var gate_vis: ColorRect
var gate_seam: ColorRect
var thread: Line2D
var bumpers := []
var lovers := []
var symbols := []
var slings := []
var hud := {}
var fx := {}
var biome = null
var charger = null
var plunger = null
var feat = null

var bump_lit := [false, false, false]
var bump_cd := [0.0, 0.0, 0.0]
var lover_hit := [false, false]
var sym_lit := [false, false, false]
var score := 0
var balls := 3
var gate_open := false
var stuck_t := 0.0
var over := false
var flip_l_on := false
var flip_r_on := false

const MAX_SPEED := 2200.0

func build(r: Node2D):
 root = r
 var refs = W.build(r)
 ball = refs.ball
 flip_l = refs.flip_l
 flip_r = refs.flip_r
 gate_shape = refs.gate_shape
 gate_vis = refs.gate_vis
 gate_seam = refs.gate_seam
 thread = refs.thread
 bumpers = refs.bumpers
 lovers = refs.lovers
 symbols = refs.symbols
 slings = refs.slings
 fx = refs.fx
 hud = H.build(r)
 ball.z_index = 10
 biome = B.new()
 biome.setup(root)
 charger = C.new()
 charger.setup(ball, flip_l, flip_r)
 plunger = P.new()
 plunger.setup(ball, refs.lane.plunger_vis)
 feat = F.build(r, refs)
 respawn()
 H.refresh(hud, score, balls, sym_lit)
 hud.overlay.text = "Зажги три печати —\nЧердак откроется"
 hud.overlay.visible = true
 var tw = root.create_tween()
 tw.tween_interval(5.0)
 tw.tween_callback(func(): hud.overlay.visible = false)

func respawn():
 ball.position = Vector2(1050, 1770)
 ball.linear_velocity = Vector2.ZERO
 stuck_t = 0.0
 if biome:
  biome.clear()

func skill_flash():
 score += 250
 H.refresh(hud, score, balls, sym_lit)
 H.flash_score(hud)

func input(event):
 var pressed = false
 var left = false
 var valid = false
 if event is InputEventKey:
  if event.keycode == KEY_LEFT or event.keycode == KEY_A:
   left = true
   valid = true
  elif event.keycode == KEY_RIGHT or event.keycode == KEY_D:
   left = false
   valid = true
  pressed = event.pressed
 elif event is InputEventScreenTouch or event is InputEventMouseButton:
  if event is InputEventMouseButton and event.button_index != MOUSE_BUTTON_LEFT:
   return
  valid = true
  pressed = event.pressed
  left = event.position.x < 510
 else:
  return
 if over and valid and pressed:
  reset()
  return
 if valid:
  if left:
   flip_l_on = pressed
   if not pressed and charger:
    charger.release(true)
  else:
   if plunger and plunger.ball_in_lane():
    if pressed:
     plunger.set_charging(true)
    else:
     if plunger.launch():
      skill_flash()
      if ball.linear_velocity.y > -2700:
       ball.linear_velocity.y = -2700
   else:
    flip_r_on = pressed
    if not pressed and charger:
     charger.release(false)

func tick(delta):
 ball.get_child(2).rotation += ball.linear_velocity.x * delta / 18.0

 if is_instance_valid(flip_l) and flip_l.has_method("set_active"):
  flip_l.set_active(flip_l_on)
 if is_instance_valid(flip_r) and flip_r.has_method("set_active"):
  flip_r.set_active(flip_r_on)

 if charger:
  charger.tick(delta, flip_l_on, flip_r_on)
 if plunger:
  plunger.tick(delta)
  plunger.check_launch_end()

 if ball.global_position.y < 340 and ball.global_position.x > 960 and ball.linear_velocity.y < 0:
  ball.linear_velocity.x = move_toward(ball.linear_velocity.x, -700, 4000 * delta)

 var hot = false
 var hot_t := 0.0
 var near_flipper = false
 if ball.global_position.distance_to(flip_l.global_position) < 260:
  near_flipper = true
 if ball.global_position.distance_to(flip_r.global_position) < 260:
  near_flipper = true
 if near_flipper:
  hot = true
  hot_t = 2.5
 else:
  hot_t -= delta
  if hot_t <= 0.0:
   hot = false

 if plunger and not plunger.is_launching:
  if ball.linear_velocity.length() > MAX_SPEED:
   ball.linear_velocity = ball.linear_velocity.normalized() * MAX_SPEED

 if biome:
  biome.tick(delta, ball)

 for s in slings:
  s.cd -= delta
  if s.cd <= 0 and ball.global_position.y < 1500 and s.area.get_overlapping_bodies().has(ball):
   s.cd = 0.25
   ball.apply_central_impulse(s.normal * 850)
   score += 10
   H.refresh(hud, score, balls, sym_lit)

 var in_lane = plunger and plunger.ball_in_lane()

 if false:
  stuck_t += delta
  if stuck_t > 6.0:
   respawn()
 else:
  stuck_t = 0.0

 if feat:
  var fg = F.tick(feat, ball, delta)
  if fg > 0:
   score += fg
   H.refresh(hud, score, balls, sym_lit)

 for i in range(3):
  bump_cd[i] -= delta
  if bumpers[i].global_position.distance_to(ball.global_position) < 45 and bump_cd[i] <= 0:
   bump_cd[i] = 0.2
   var dir = (ball.global_position - bumpers[i].global_position).normalized()
   if dir.length() < 0.1:
    dir = Vector2(0, -1)
   dir = dir.rotated(randf_range(-0.25, 0.25))
   ball.apply_central_impulse(dir * 700)
   bumpers[i].get_child(1).modulate = Color(4, 4, 4, 1)
   var twb = root.create_tween()
   twb.tween_property(bumpers[i].get_child(1), "modulate", Color(1, 1, 1, 1), 0.2)
   if hot and not bump_lit[i]:
    bump_lit[i] = true
    bumpers[i].get_child(2).color = Color(1, 0.65, 0.25)
    score += 100
    H.refresh(hud, score, balls, sym_lit)
    if bump_lit[0] and bump_lit[1] and bump_lit[2]:
     score += 1000
     over = true
     hud.overlay.text = "УРОВЕНЬ ПРОЙДЕН\n\nтапни — новый круг"
     hud.overlay.visible = true

 for i in range(2):
  if hot and not lover_hit[i] and lovers[i].global_position.distance_to(ball.global_position) < 55:
   lover_hit[i] = true
   var dir = (ball.global_position - lovers[i].global_position).normalized()
   dir = dir.rotated(randf_range(-0.4, 0.4))
   ball.apply_central_impulse(dir * 500)
   lovers[i].get_child(2).color = Color(1, 0.85, 0.4)
   thread.default_color = Color(1, 0.8, 0.4, 0.9)
   if lover_hit[0] and lover_hit[1]:
    score += 500
    H.refresh(hud, score, balls, sym_lit)
    lover_hit = [false, false]
    lovers[0].get_child(2).color = Color(0.85, 0.65, 0.25)
    lovers[1].get_child(2).color = Color(0.85, 0.65, 0.25)
    thread.default_color = Color(1, 0.75, 0.35, 0.4)
   else:
    var twl = root.create_tween()
    twl.tween_interval(2.0)
    twl.tween_callback(func():
     if lover_hit[0] != lover_hit[1]:
      lover_hit = [false, false]
      lovers[0].get_child(2).color = Color(0.85, 0.65, 0.25)
      lovers[1].get_child(2).color = Color(0.85, 0.65, 0.25)
      thread.default_color = Color(1, 0.75, 0.35, 0.4))

 for i in range(3):
  if hot and not sym_lit[i] and symbols[i].get_child(1).global_position.distance_to(ball.global_position) < 50:
   sym_lit[i] = true
   symbols[i].get_child(1).color = Color(1, 0.9, 0.5)
   score += 50
   H.refresh(hud, score, balls, sym_lit)
   A.progress(fx, sym_lit)
   if sym_lit[0] and sym_lit[1] and sym_lit[2]:
    gate_open = true
    gate_shape.disabled = true
    gate_vis.visible = false
    gate_seam.visible = false
    A.attic_open(fx)

 if gate_open and ball.global_position.y < 20 and ball.global_position.x > 390 and ball.global_position.x < 630:
  score += 500
  H.refresh(hud, score, balls, sym_lit)
  respawn()

 if ball.global_position.y > 1860 and not in_lane:
  balls -= 1
  H.refresh(hud, score, balls, sym_lit)
  if balls <= 0:
   over = true
   hud.overlay.text = "ТЬМА ЗАБРАЛА МЯЧИ\n\nтапни — новый круг"
   hud.overlay.visible = true
  respawn()

func reset():
 score = 0
 balls = 3
 over = false
 gate_open = false
 gate_shape.disabled = false
 gate_vis.visible = true
 gate_seam.visible = true
 bump_lit = [false, false, false]
 for i in range(3):
  bumpers[i].get_child(2).color = Color(0.35, 0.28, 0.12)
 lover_hit = [false, false]
 sym_lit = [false, false, false]
 for i in range(3):
  symbols[i].get_child(1).color = Color(0.8, 0.62, 0.25)
 thread.default_color = Color(1, 0.75, 0.35, 0.4)
 hud.overlay.visible = false
 A.reset_fx(fx)
 respawn()
 H.refresh(hud, score, balls, sym_lit)
