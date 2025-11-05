extends State

@onready var idle_timer: Timer = $IdleTimer



@export var state_select_target: State

func enter() -> void:
    
    print("state entered - idle")
    idle_timer.start()
    
func exit() -> void:
    idle_timer.stop()


func _on_timer_timeout() -> void:
    change_state_requested.emit(state_select_target)
