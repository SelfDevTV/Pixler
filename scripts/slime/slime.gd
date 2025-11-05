class_name Slime
extends Node2D

var states: Dictionary[String, SlimeState] 
var target: Vector2

var current_state: SlimeState

func _ready() -> void:
    
    states = {
        "idle": StateIdle.new(self),
        "select_target": StateSelectTarget.new(self)
    }
    current_state = states["idle"]

func change_state(new: String):
    if current_state:
        current_state.exit()
    current_state = states[new]
    current_state.enter()
    
func _process(delta: float) -> void:
    if current_state:
        current_state.process(delta)
