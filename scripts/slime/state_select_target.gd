extends State

@export var idle_state: State
@export var moving_state: State

func enter() -> void:
    if GridManager.has_unpainted_cells():
        var target = slime.get_next_target()
        var target_world = GridManager.cell_to_world(target)
        slime.next_target = target_world
        change_state_requested.emit(moving_state)
    else:
        change_state_requested.emit(idle_state)
    
