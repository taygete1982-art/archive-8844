extends Node2D

signal all_symbols_lit
signal symbol_lit(lit_count)

var symbols_lit := 0
var total_symbols := 3

func _ready():
	for child in get_children():
		if child is Area2D and child.name.begins_with("Symbol"):
			child.body_entered.connect(_on_symbol_hit.bind(child))

func _on_symbol_hit(body, symbol):
	if body.name != "Ball":
		return
	if symbol.get_meta("lit", false):
		return
	symbol.set_meta("lit", true)
	symbols_lit += 1
	var lit = symbol.get_node_or_null("Lit")
	if lit:
		var tw = lit.create_tween()
		tw.tween_property(lit, "modulate:a", 1.0, 0.25)
	var fx = get_node_or_null("/root/FX")
	if fx:
		fx.ring(symbol.global_position, Color(1, 0.75, 0.35))
		fx.shake(3)
	symbol_lit.emit(symbols_lit)
	if symbols_lit >= total_symbols:
		all_symbols_lit.emit()

func reset():
	symbols_lit = 0
	symbol_lit.emit(0)
	for child in get_children():
		if child is Area2D and child.name.begins_with("Symbol"):
			child.set_meta("lit", false)
			var lit = child.get_node_or_null("Lit")
			if lit:
				lit.modulate.a = 0.0