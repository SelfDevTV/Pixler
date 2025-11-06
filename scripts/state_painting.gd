extends State

@onready var paint_timer: Timer = $PaintTimer
@export var idle_state: State


func enter() -> void:
    paint_timer.wait_time = slime.paint_speed
    paint_timer.start()
    slime.animation_player.play("paint")
    print("cell pos for paint: ", GridManager.world_to_cell(slime.global_position))
    slime.progress_bar.max_value = paint_timer.wait_time
    slime.progress_bar.value = 0
    

func _on_paint_timer_timeout() -> void:
    slime.animation_player.stop()
    paint_timer.stop()
    var cell = GridManager.world_to_cell(slime.next_target)
    GridManager.mark_cell_painted(cell)
    change_state_requested.emit(idle_state)
    
func update(delta: float) -> void:
    slime.progress_bar.value = paint_timer.wait_time - paint_timer.time_left

    
