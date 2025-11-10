class_name Main
extends Node2D

@export var painting: Painting


func _ready() -> void:
    GridManager.load_painting(painting)
    EconomyManager.set_coins(SaveManager.load_game().coins)
    for x in range(SaveManager.load_game().slime_count):
        SlimeManager.add_slime()
