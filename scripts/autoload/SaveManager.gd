extends Node

# Глобальный менеджер прогресса и сохранений
# Хранит данные о прокачке, артефактах и уровне престижа

const SAVE_PATH = "user://save_data.json"

# Состояние игрока
var silver: int = 0
var prestige_level: int = 1
var total_experience: int = 0

# Прокачка (уровни веток от 1 до 10)
var upgrades = {
	"flipper_speed": 1,
	"flipper_size": 1,
	"ball_mass": 1,
	"ball_precision": 1,
	"defense_barrier": 1
}

# Коллекция музея (ID артефактов)
var collected_artifacts = []

# Статистика текущей сессии
var current_session_score = 0
var current_session_artifacts = []

func _ready():
	load_game()

func add_silver(amount: int):
	silver += amount
	save_game()

func collect_artifact(id: String):
	if not id in collected_artifacts:
		collected_artifacts.append(id)
		save_game()

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data = {
		"silver": silver,
		"prestige": prestige_level,
		"upgrades": upgrades,
		"artifacts": collected_artifacts,
		"exp": total_experience
	}
	file.store_string(JSON.stringify(data))

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	if error == OK:
		var data = json.data
		silver = data.get("silver", 0)
		prestige_level = data.get("prestige", 1)
		upgrades = data.get("upgrades", upgrades)
		collected_artifacts = data.get("artifacts", [])
		total_experience = data.get("exp", 0)
