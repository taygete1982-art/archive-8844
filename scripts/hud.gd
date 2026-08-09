extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var balls_label = $BallsLabel
@onready var symbols_label = $SymbolsLabel
@onready var overlay_label = $OverlayLabel

var overlay_time_ms := 0
var overlay_kind := ""

func _ready():
	if overlay_label:
		overlay_label.visible = false
	_on_symbol_lit(0)
	var sm = get_node_or_null("/root/ScoreManager")
	if sm:
		sm.score_changed.connect(_on_score)
		sm.balls_changed.connect(_on_balls)
		sm.game_over.connect(_on_game_over)
		sm.game_restarted.connect(_on_restarted)
		sm.level_completed.connect(_on_level_complete)
		_on_score(sm.score)
		_on_balls(sm.balls)
	await get_tree().process_frame
	var symbols = get_tree().current_scene.get_node_or_null("Symbols")
	if symbols and symbols.has_signal("symbol_lit"):
		symbols.symbol_lit.connect(_on_symbol_lit)

func _process(_delta):
	if overlay_label and overlay_label.visible and (Time.get_ticks_msec() - overlay_time_ms) > 800:
		if Input.is_anything_pressed():
			var sm = get_node_or_null("/root/ScoreManager")
			if sm:
				sm.start_new_game()

func _on_score(value):
	if score_label:
		score_label.text = str(value)

func _on_balls(value):
	if balls_label == null:
		return
	var s = ""
	for i in range(value):
		s += "●  "
	balls_label.text = s

func _on_symbol_lit(count):
	if symbols_label == null:
		return
	var s = ""
	for i in range(3):
		s += "◆" if i < count else "◇"
		if i < 2:
			s += "   "
	symbols_label.text = s

func _on_level_complete():
	if overlay_label:
		overlay_label.text = "УРОВЕНЬ ПРОЙДЕН\n\n«Кто шёл по песку, тот знает —\nслед длиннее шага.»\n\nтапни — и круг начнётся заново"
		overlay_label.visible = true
		overlay_time_ms = Time.get_ticks_msec()
		overlay_kind = "level_complete"

func _on_game_over():
	if overlay_label:
		overlay_label.text = "ПУСТЫНЯ ЗАБРАЛА МЯЧИ\n\nтапни — и круг начнётся заново"
		overlay_label.visible = true
		overlay_time_ms = Time.get_ticks_msec()
		overlay_kind = "game_over"

func _on_restarted():
	if overlay_label:
		overlay_label.visible = false
	overlay_kind = ""
	_on_symbol_lit(0)