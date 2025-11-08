class_name Main
extends Node2D

@export var painting: Painting


func _ready() -> void:
    await get_tree().process_frame
    GridManager.load_painting(painting)
    await get_tree().process_frame
    
    


func _on_button_pressed() -> void:
    SlimeManager.purchase_slime()
