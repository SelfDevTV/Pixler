class_name Main
extends Node2D

@export var painting: Painting


func _ready() -> void:
    GridManager.load_painting(painting)
    
    


func _on_button_pressed() -> void:
    SlimeManager.purchase_slime()
