extends Node2D

var table = null

func _ready():
	table = preload("res://scripts/game/table.gd").new()
	table.build(self)

func _input(event):
	if table:
		table.input(event)

func _physics_process(delta):
	if table:
		table.tick(delta)
