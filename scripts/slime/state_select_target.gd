extends State

@export var idle_state: State
@export var moving_state: State

func enter() -> void:
    if GridManager.has_unpainted_cells():
        var cells = GridManager.get_unpainted_cell_positions()
        var random_cell_pos = cells.pick_random()
        var cell_pos_world = GridManager.cell_to_world(random_cell_pos)
        slime.next_target = cell_pos_world
        change_state_requested.emit(moving_state)
    else:
        change_state_requested.emit(idle_state)
    
