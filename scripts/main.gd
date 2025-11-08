class_name Main
extends Node2D

@export var painting: Painting


func _ready() -> void:
    GridManager.load_painting(painting)
