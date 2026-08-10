extends Node2D

var Table = preload("res://scripts/game/table.gd")
var table = null

func _ready():
    table = Table.new()
    table.build(self)

func _input(event):
    if table:
        table.input(event)

func _process(delta):
    if table:
        table.tick(delta)
