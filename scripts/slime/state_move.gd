extends State

@export var painting_state: State

func update(delta: float):
    var dir = slime.global_position.direction_to(slime.next_target)
    slime.global_position += dir * slime.move_speed * delta
    if slime.global_position.distance_to(slime.next_target) <= 10:
        change_state_requested.emit(painting_state)
    
