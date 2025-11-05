extends State

@onready var timer: Timer = $Timer


@export var state_select_target: State

func enter() -> void:
    print("state entered - idle")
    timer.start()
    
func exit() -> void:
    timer.stop()


func _on_timer_timeout() -> void:
    change_state_requested.emit(state_select_target)
