class_name StateSelectTarget
extends SlimeState

func enter() -> void:
    var targets = GridManager.get_unpainted_cell_positions()
    if targets.size() == 0:
        slime.change_state("idle")
    else:
        var target = targets.pick_random()
        slime.target = target
    
    
