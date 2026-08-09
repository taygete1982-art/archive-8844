extends Area2D

var busy := false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name != "Ball" or busy:
		return
	busy = true
	var root = get_tree().current_scene

	var sm = get_node_or_null("/root/ScoreManager")
	if sm:
		sm.add_score(500)
	var fx = get_node_or_null("/root/FX")
	if fx:
		fx.float_text(Vector2(540, 140), "ЧЕРДАК +500", Color(1, 0.95, 0.7))
		fx.ring(body.global_position, Color(1, 0.9, 0.6), 3.0)
		fx.shake(10)

	body.gravity_scale = 0.0
	body.linear_velocity = Vector2.ZERO
	body.global_position = Vector2(540, -140)

	await get_tree().create_timer(1.2).timeout

	var spawn = root.get_node_or_null("BallSpawn")
	if spawn:
		if body.has_method("reset_echo"):
			body.reset_echo()
		body.global_position = spawn.global_position
		body.linear_velocity = Vector2.ZERO
		body.gravity_scale = 1.0

	var arch = root.get_node_or_null("ArchGate")
	if arch and arch.has_method("close_gate"):
		arch.close_gate()
	var symbols = root.get_node_or_null("Symbols")
	if symbols and symbols.has_method("reset"):
		symbols.reset()

	busy = false