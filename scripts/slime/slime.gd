class_name Slime
extends Node2D

var next_target: Vector2
var frontier: Dictionary[Vector2i, bool]
var starting_point: Vector2i
var target_selection_mode: TargetSelectionMode = TargetSelectionMode.ORGANIC

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var progress_bar: ProgressBar = $ProgressBar

enum TargetSelectionMode {
   RANDOM,
    ORGANIC 
}

var move_speed: float
var paint_speed: float

func _ready() -> void:
    calculate_stats()
    UpgradeManager.upgrade_purchased.connect(_on_upgrade_purchased)

func calculate_stats() -> void:
    move_speed = UpgradeManager.get_upgrade_effect(UpgradeManager.UPGRADE_TYPE.MOVE_SPEED)
    paint_speed = UpgradeManager.get_upgrade_effect(UpgradeManager.UPGRADE_TYPE.PAINT_SPEED)

func _on_upgrade_purchased(_upgrade: UpgradeManager.UPGRADE_TYPE, _new_level: int):
    calculate_stats()
    
func get_next_target() -> Vector2i:
    match target_selection_mode:
        TargetSelectionMode.RANDOM:
            return _get_random_target()
        TargetSelectionMode.ORGANIC:
            return _get_organic_target()
    return Vector2i.ZERO
    
func _get_organic_target() -> Vector2i:
    
    if starting_point == Vector2i.ZERO:
        starting_point = _get_random_target()
        return starting_point
    
    #var unpainted_neighbours = []
    for x in range(-1, 2, 1):
        for y in range(-1, 2, 1):
            if x == 0 and y == 0:
                continue
            var cell_pos = starting_point + Vector2i(x, y)
            if not GridManager.has_cell_at(cell_pos):
                continue
            if GridManager.is_cell_painted(cell_pos):
                continue
            if not frontier.has(cell_pos):
                frontier.set(cell_pos, true)
            # todo, add neightbours
    if frontier.size() == 0:
        starting_point = _get_random_target()
        return starting_point
    else:
        var next = frontier.keys().pick_random()
        starting_point = next
        frontier.erase(next)
        return starting_point
    
    

func _get_random_target() -> Vector2i:
    var cells = GridManager.get_unpainted_cell_positions()
    var random_cell_pos = cells.pick_random()
    return random_cell_pos
