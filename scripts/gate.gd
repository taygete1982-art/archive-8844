extends StaticBody2D

func open():
	collision_layer = 0
	var v = get_node_or_null("GateVisual")
	if v:
		var tw = v.create_tween()
		tw.tween_property(v, "modulate:a", 0.0, 0.8)

func close():
	collision_layer = 1
	var v = get_node_or_null("GateVisual")
	if v:
		v.modulate.a = 0.0
		var tw = v.create_tween()
		tw.tween_property(v, "modulate:a", 1.0, 0.8)