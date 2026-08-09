extends Node2D

@export var bonus_points := 200

var is_open := false
var veil_tw: Tween = null

func _ready():
	var trigger = $Trigger
	if trigger:
		trigger.body_entered.connect(_on_body_entered)
	var symbols = get_parent().get_node_or_null("Symbols")
	if symbols and symbols.has_signal("all_symbols_lit"):
		symbols.all_symbols_lit.connect(open_gate)
	_start_veil_loop()

func _start_veil_loop():
	var veil = get_node_or_null("Veil")
	if veil:
		veil_tw = create_tween().set_loops()
		veil_tw.tween_property(veil, "modulate:a", 0.65, 1.2)
		veil_tw.tween_property(veil, "modulate:a", 1.0, 1.2)

func _get_attic_node(path):
	return get_tree().current_scene.get_node_or_null("Attic/" + path)

func open_gate():
	if is_open:
		return
	is_open = true
	if veil_tw and veil_tw.is_valid():
		veil_tw.kill()
	var veil = get_node_or_null("Veil")
	if veil:
		var tw = veil.create_tween()
		tw.tween_property(veil, "modulate:a", 0.0, 1.0)
	var gate = _get_attic_node("AtticGate")
	if gate and gate.has_method("open"):
		gate.open()
	var rays = _get_attic_node("AtticRays")
	if rays:
		rays.visible = true
		rays.modulate.a = 0.0
		var tw = rays.create_tween()
		tw.tween_property(rays, "modulate:a", 0.8, 1.0)
	var fx = get_node_or_null("/root/FX")
	if fx:
		fx.float_text(global_position + Vector2(0, -60), "ЧЕРДАК ОТКРЫТ", Color(1, 0.95, 0.6))
		fx.ring(global_position, Color(1, 0.9, 0.5), 3.0)
		fx.shake(6)

func close_gate():
	is_open = false
	var veil = get_node_or_null("Veil")
	if veil:
		veil.modulate.a = 0.0
		_start_veil_loop()
	var gate = _get_attic_node("AtticGate")
	if gate and gate.has_method("close"):
		gate.close()
	var rays = _get_attic_node("AtticRays")
	if rays:
		var tw = rays.create_tween()
		tw.tween_property(rays, "modulate:a", 0.0, 0.8)
		tw.tween_callback(func(): rays.visible = false)

func _on_body_entered(body):
	if body.name == "Ball":
		if not is_open:
			var dir = (body.global_position - global_position).normalized()
			body.apply_central_impulse(dir * 200)
			var fx = get_node_or_null("/root/FX")
			if fx:
				fx.ring(body.global_position, Color(0.8, 0.6, 0.35), 1.2)