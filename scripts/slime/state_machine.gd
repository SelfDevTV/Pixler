class_name StateMachine
extends Node

var states: Array[State] = []

@export var slime: Slime
@export var initial_state: State

var current_state: State

func _ready() -> void:
    if not slime:
        slime = get_parent() as Slime
    if not initial_state:
        return
    for c in get_children():
        if c is State:
            states.append(c)
            c.slime = slime
            c.change_state_requested.connect(state_change_requested)

    current_state = initial_state
    current_state.enter()

func state_change_requested(new: State):
    current_state.exit()
    current_state = new
    current_state.enter()
    
func _process(delta: float) -> void:
    current_state.update(delta)
