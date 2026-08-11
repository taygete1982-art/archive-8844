extends Node2D

var Table = preload("res://scripts/game/table.gd")

var table_instance

func _ready():
    table_instance = Table.new()
    table_instance.build(self)

func _physics_process(delta):
    if table_instance:
        table_instance.tick(delta)

func _unhandled_input(event):
    if table_instance:
        table_instance.input(event)
