class_name StateIdle
extends SlimeState

var idle_timer := 0.0
var idle_duration := 1.0

func enter() -> void:
    idle_timer = 0.0

func process(delta: float) -> void:
    idle_timer += delta
    if idle_timer >= idle_duration:
        slime.change_state("select_target")
