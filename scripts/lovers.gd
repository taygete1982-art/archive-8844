extends StaticBody2D

@export var partner: NodePath
@export var glow_color := Color(1, 0.85, 0.4, 1)
@export var combo_bonus := 500
@export var reset_delay := 2.0

var is_hit := false
var partner_node = null
var reset_timer: Timer = null

func _ready():
	if partner:
		partner_node = get_node(partner)
		if partner_node and partner_node.has_method("set_partner"):
			partner_node.set_partner(self)
	var trigger = get_node_or_null("Trigger")
	if trigger:
		trigger.body_entered.connect(_on_body_entered)
	reset_timer = Timer.new()
	reset_timer.one_shot = true
	reset_timer.timeout.connect(_on_reset_timer_timeout)
	add_child(reset_timer)

func set_partner(other):
	partner_node = other

func _on_body_entered(body):
	if body.name == "Ball" and not is_hit:
		is_hit = true
		var dir = (body.global_position - global_position).normalized()
		if dir.length() < 0.1:
			dir = Vector2(0, -1)
		# Случайный угол — мяч не зависнет на месте
		dir = dir.rotated(randf_range(-0.4, 0.4))
		body.apply_central_impulse(dir * 450)
		_flash()
		var thread = get_node_or_null("../LoveThread")
		if thread:
			thread.default_color = Color(1, 0.8, 0.4, 0.8)
		if partner_node and partner_node.is_hit:
			var sm = get_node_or_null("/root/ScoreManager")
			if sm:
				sm.add_score(combo_bonus)
			var fx = get_node_or_null("/root/FX")
			if fx:
				fx.float_text(global_position + Vector2(0, -50), "ВОЗЛЮБЛЕННЫЕ +" + str(combo_bonus), Color(1, 0.9, 0.5))
				fx.ring(global_position, Color(1, 0.85, 0.4), 2.5)
				fx.ring(partner_node.global_position, Color(1, 0.85, 0.4), 2.5)
				fx.shake(8)
			print("Возлюбленные! +", combo_bonus)
			reset_lovers()
		else:
			reset_timer.start(reset_delay)

func _flash():
	var visual = get_node_or_null("Visual")
	if visual:
		visual.scale = Vector2(1.6, 1.6)
		visual.modulate = Color(2.5, 2.5, 2.5, 1)
		var tw = visual.create_tween()
		tw.tween_property(visual, "scale", Vector2(1, 1), 0.3)
		tw.parallel().tween_property(visual, "modulate", Color(1, 1, 1, 1), 0.3)

func _on_reset_timer_timeout():
	if not (partner_node and partner_node.is_hit):
		reset_self()

func reset_self():
	is_hit = false
	var visual = get_node_or_null("Visual")
	if visual:
		visual.modulate = Color(1, 1, 1, 1)
	var thread = get_node_or_null("../LoveThread")
	if thread:
		thread.default_color = Color(0.9, 0.7, 0.3, 0.25)
	reset_timer.stop()

func reset_lovers():
	reset_self()
	if partner_node:
		partner_node.reset_self()

func reset_all():
	reset_lovers()