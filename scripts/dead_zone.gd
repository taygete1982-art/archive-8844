extends Area2D

@export var ball_spawn_path : NodePath = "../BallSpawn"
@export var ball_save_time := 5.0

var spawn_time_ms := 0
var ball_save_used := false
var game_active := true
var cooldown := 0.0

func _ready():
	body_entered.connect(_on_body_entered)
	spawn_time_ms = Time.get_ticks_msec()
	var sm = get_node_or_null("/root/ScoreManager")
	if sm:
		if sm.has_signal("game_over") and not sm.game_over.is_connected(_on_game_over):
			sm.game_over.connect(_on_game_over)
		if sm.has_signal("game_restarted") and not sm.game_restarted.is_connected(_on_restarted):
			sm.game_restarted.connect(_on_restarted)

func _on_game_over():
	game_active = false
	print("DeadZone: игра окончена")

func _on_restarted():
	game_active = true
	ball_save_used = false
	cooldown = 0.5
	respawn_now()

func _process(delta):
	cooldown -= delta
	if not game_active:
		return
	# Страховка: мяч лежит/катится внизу и почти остановился = слив
	var ball = get_node_or_null("../Ball")
	if ball and ball.global_position.y > 1750 and ball.linear_velocity.length() < 40:
		try_drain()

func _on_body_entered(body):
	if body.name == "Ball":
		try_drain()

func try_drain():
	if not game_active or cooldown > 0:
		return
	cooldown = 1.0

	var elapsed = (Time.get_ticks_msec() - spawn_time_ms) / 1000.0

	# Милосердие пустыни: первые 5 секунд после спавна мяч возвращается бесплатно
	if not ball_save_used and elapsed <= ball_save_time:
		ball_save_used = true
		print("Милосердие пустыни: мяч возвращён")
		respawn_now()
		return

	var sm = get_node_or_null("/root/ScoreManager")
	if sm and sm.has_method("lose_ball"):
		sm.lose_ball()
		if sm.balls > 0:
			ball_save_used = false
			respawn_now()
		else:
			print("Мячей не осталось — тапни для новой игры")
	else:
		respawn_now()

func respawn_now():
	var ball = get_node_or_null("../Ball")
	var spawn = get_node_or_null(ball_spawn_path)
	if ball and spawn:
		if ball.has_method("reset_echo"):
			ball.reset_echo()
		ball.global_position = spawn.global_position
		ball.linear_velocity = Vector2.ZERO
		ball.angular_velocity = 0
		ball.apply_central_impulse(Vector2(randf_range(-100, 100), 0))
		spawn_time_ms = Time.get_ticks_msec()
		print("Мяч возвращён на спавн")