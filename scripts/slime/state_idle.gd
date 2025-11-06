extends State

@onready var idle_timer: Timer = $IdleTimer

@export var idle_time: float = 1.5

@export var state_select_target: State

func enter() -> void:
    
    idle_timer.wait_time = idle_time
    idle_timer.start()
    
func exit() -> void:
    idle_timer.stop()


func _on_timer_timeout() -> void:
    change_state_requested.emit(state_select_target)
