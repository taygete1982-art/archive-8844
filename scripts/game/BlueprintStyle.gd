extends Node2D

# Скрипт для стилизации элементов под чертёж
# Автоматически настраивает визуальные параметры

@export var line_color: Color = Color.WHITE
@export var line_width: float = 2.0

func _ready():
	apply_blueprint_style()

func apply_blueprint_style():
	# Ищем все узлы Line2D и применяем стиль
	for child in get_children():
		if child is Line2D:
			child.default_color = line_color
			child.width = line_width
			child.antialiased = true
