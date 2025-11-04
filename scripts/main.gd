class_name Main
extends Node2D

@export var painting: Painting


func _ready() -> void:
    var cells = painting.create_cells()
    print(cells.size())
