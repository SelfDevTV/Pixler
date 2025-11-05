extends State

@onready var paint_timer: Timer = $PaintTimer

func enter() -> void:
    paint_timer.wait_time = slime.paint_speed
    paint_timer.start()

func _on_paint_timer_timeout() -> void:
    paint_timer.stop()
     

func update(delta: float):
    # TODO: update painting progress on that cell
    pass
