
class_name State
extends Node


var slime: Slime
signal change_state_requested(new: State)

func enter() -> void:
    pass

func exit() -> void:
    pass

func update(delta: float) -> void:
    pass
