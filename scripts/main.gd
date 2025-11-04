class_name Main
extends Node2D

@export var painting: Painting


func _ready() -> void:
    await get_tree().process_frame
    GridManager.load_painting(painting)
    GridManager.mark_cell_painted(Vector2i(0, 0))
